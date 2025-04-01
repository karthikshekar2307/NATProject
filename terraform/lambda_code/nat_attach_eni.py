import boto3
import time
import os

ec2 = boto3.client('ec2')
asg = boto3.client('autoscaling')

def lambda_handler(event, context):
    """
    1) Identify which ENI is the secondary interface (DeviceIndex=1) on the NAT instance.
    2) Wait for the newly launched instance to be running.
    3) Disable src/dest check on the new instance.
    4) Detach the NAT ENI from the old instance, if any.
    5) Attach NAT ENI to the new instance.
    6) Complete the lifecycle action to move from Pending:Wait to InService.
    """

    # You might pass the NAT instance ID via environment variable:
    nat_instance_id = os.environ.get('NAT_INSTANCE_ID')
    if not nat_instance_id:
        raise ValueError("Missing environment variable: NAT_INSTANCE_ID")

    # 1) Find the NAT instance's *secondary* ENI (device index = 1).
    #    This is the 'static' ENI we want to shuffle around.
    nat_desc = ec2.describe_instances(InstanceIds=[nat_instance_id])
    reservations = nat_desc.get('Reservations', [])
    if not reservations or not reservations[0].get('Instances'):
        raise RuntimeError(f"NAT instance {nat_instance_id} not found")

    nat_instance_data = reservations[0]['Instances'][0]
    network_interfaces = nat_instance_data.get('NetworkInterfaces', [])

    # Filter for the interface with device index == 1
    nat_eni_id = None
    for iface in network_interfaces:
        # Some OSs might name them differently, but AWS device index=1 is typically the second ENI
        if iface['Attachment']['DeviceIndex'] == 1:
            nat_eni_id = iface['NetworkInterfaceId']
            break

    if not nat_eni_id:
        raise RuntimeError(f"No secondary ENI (device=1) found on NAT instance {nat_instance_id}")

    print(f"Found NAT secondary ENI {nat_eni_id} on NAT instance {nat_instance_id}")

    # 2) The newly launched instance that triggered the lifecycle event:
    instance_id = event['detail']['EC2InstanceId']
    print(f"Handling launch for instance {instance_id}")

    # 3) Wait for the newly launched instance to be running
    waiter = ec2.get_waiter('instance_running')
    waiter.wait(InstanceIds=[instance_id])
    print(f"Instance {instance_id} is now running")

    # Disable source/dest check
    ec2.modify_instance_attribute(
        InstanceId=instance_id,
        SourceDestCheck={'Value': False}
    )
    print(f"Disabled src/dest check on instance {instance_id}")

    # 4) Detach NAT ENI from previous instance, if it's attached
    eni_desc = ec2.describe_network_interfaces(NetworkInterfaceIds=[nat_eni_id])
    attachment = eni_desc['NetworkInterfaces'][0].get('Attachment')
    if attachment:
        attach_inst = attachment['InstanceId']
        print(f"NAT ENI {nat_eni_id} currently attached to {attach_inst}, detaching...")
        ec2.detach_network_interface(AttachmentId=attachment['AttachmentId'], Force=True)
        time.sleep(5)  # Wait a bit for AWS to finalize detachment

    # 5) Attach ENI to the new instance
    print(f"Attaching NAT ENI {nat_eni_id} to instance {instance_id} (deviceIndex=1)")
    ec2.attach_network_interface(
        NetworkInterfaceId=nat_eni_id,
        InstanceId=instance_id,
        DeviceIndex=1
    )

    # 6) Complete the lifecycle action
    asg.complete_lifecycle_action(
        LifecycleHookName=event['detail']['LifecycleHookName'],
        AutoScalingGroupName=event['detail']['AutoScalingGroupName'],
        LifecycleActionResult='CONTINUE',
        InstanceId=instance_id
    )

    print("Lifecycle action completed; instance should proceed to InService.")
