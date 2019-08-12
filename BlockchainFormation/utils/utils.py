import datetime
import time
import numpy as np
import paramiko
from scp import SCPClient

# File containing helper functions


def wait_till_done(ssh_clients, ips, total_time, delta, path, message, typical_time, logger):

    """
    Waits until a job is done on all of the target VMs
    :param ssh_clients: ssh_clients for VMs on which something must be completed
    :param ips: ips for the VMs on which something must be completed (for logging only)
    :param total_time: maximum total waiting time in seconds
    :param delta: time between two successive attempts
    :param path: path of the file which is created at completion
    :param message: content of the file which is created at completion, if message equals False then no message is required
    :param typicalTime: the time which it usually takes
    :param logger: the logger of the parent (calling) script

    :return: True if all files with the desired content were created, False otherwise
    """

    status_flags = np.zeros(len(ssh_clients), dtype=bool)
    timer = 0

    while (False in status_flags and timer < total_time):
        time.sleep(delta)
        timer += delta
        logger.debug(f" --> Waited {timer} seconds so far, {total_time - timer} seconds left before abort (it usually takes less than {np.ceil(typical_time/60)} minutes)")

        for index, ip in enumerate(ips):
            if (status_flags[index] == False):
                try:
                    client_sftp = ssh_clients[index].open_sftp()
                    client_sftp.stat(path)
                    if (message != False):
                        stdin, stdout, stderr = ssh_clients[index].exec_command(f"tail -n 1 {path}")
                        if stdout.readlines()[0] == f"{message}\n":
                            status_flags[index] = True
                            logger.debug(f"   --> ready on {ip}")
                            continue
                        else:
                            logger.debug(f"   --> not yet ready on {ip}")
                            continue

                    status_flags[index] = True
                    logger.debug(f"   --> ready on {ip}")

                except:
                    logger.debug(f"   --> not yet ready on {ip}")

    if (False in status_flags):
        try:
            logger.error(f"Failed VMs: {[ips[x] for x in np.where(status_flags != True)]}")
        except:
            pass
        return False
    else:
        return True

def datetimeconverter(o):
    """Converter to make datetime objects json dumpable"""
    if isinstance(o, datetime.datetime):
        return o.__str__()

def yes_or_no(question):
    reply = str(input(question + ' (y/n): ')).lower().strip()
    if reply[0] == 'y':
        return 1
    elif reply[0] == 'n':
        return 0
    else:
        return yes_or_no("Please Enter (y/n) ")