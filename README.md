# PECA Classroom Day Feb 10 2022 Exercises

## Preparations

### Virtual Instances

Each group will be assigned a virtual machine on Amazon Web Services (AWS) running Ubuntu, which you will have to use to perform the below exercises.

To access this instance:

- On Linux/Mac OS: open a terminal window and execute:

  ```bash
  ssh -o PubKeyAuthentication=no ubuntu@<ip address>
  ```
  
  Where `<ip address>` corresponds to the public IP address of the virtual machine you have been assigned.

- On Windows, you will have to open an SSH session using PuTTy or the experimental `ssh` client for the Windows console.
  Point your SSH session to the IP address you have been given, using password authentication and the login user `ubuntu`.

The password for the instance is `pecaclassroom`.

### Jupyter Server

Once you have logged in to your assigned instance on AWS, you will have to start the Jupyter Server we will be using to analyze the experimental results.
To do so:

1. First create a directory to hold your experimental results: `mkdir -p ~/results`.
2. Next, start the Jupyter Server with the following command:

   ```bash
   docker run --rm -it -d -p 8080:8080/tcp \
       -v ${PWD}/results:/home/jupyter/peca_classroom/experiments \
       molguin/peca-classroom
   ```
   
   This will start a Docker container running a Jupyter Server listening on port `8080` of your AWS instance.
3. Once the command has finished, on your local computer, access the remote Jupyter Server by opening a browser and heading to `http://<ip address>:8080`, where `<ip address>` corresponds to the IP address of your AWS instance.
4. Log in to Jupyter using the password `pecaclassroom`.
5. Open the `analysis.ipynb` file, which corresponds to a Jupyter Notebook we will use for analyzing experimental results.
6. Run it once by clicking on the double-arrows on the toolbar to verify that it works.
    

## Exercises

### RTT Measurements

The virtual machine you have been assigned is connected to a number of other machines in different regions of the world: Sweden (eu-north-1), Germany (eu-central-1), and US East Coast (us-east-1).
Your first task will be to establish base measurements of the round-trip times of network packets to these regions.

For each region, measure the average round-trip time over 50 packets using `ping`.
For instance, for Sweden:

```bash
ping -c 50 eu-north-1
```

### Workflow for the CLEAVE Experiments

In each of the next experiments, you will run the CLEAVE toolkit, placing the controller on different locations and the parametrizing the plant.
Below you will find step-by-step instructions on the workflow you should follow for each of these experiments:

1. Deploy the controller to a specific region `<region>`:

  ``` bash
  DOCKER_HOST=<region> docker run --rm -it -d --network host \
      -e PORT=50000 molguin/cleave:cleave \
      -vvvvv run-controller \
      examples/inverted_pendulum/controller/config.py
  ```

2. Make a new directory under the result directory we created for Jupyter in [the previous section](#jupyter-server), to collect the results of the current experiment: `mkdir -p ~/results/<experiment_name>`.

3. Run the plant locally, pointing it to a controller on `<region>`:

   ``` bash
   docker run --rm -it --network host \
       -v ${PWD}/results/<experiment_name>:/opt/plant_metrics:rw \
       -e CONTROLLER_ADDRESS=$(dig +short <region>) \
       -e CONTROLLER_PORT=50000 \
       -e TICK_RATE=120 \
       -e SAMPLE_RATE=20 \
       -e EMU_DURATION=30s \
       -e PEND_MASS=0.2 \
       -e PEND_LEN=1.2 \
       molguin/cleave:cleave -vvvv run-plant \
       examples/inverted_pendulum/plant/config.py
   ```
   
   A couple of things to note:
   1. `-v ~/results/<experiment_name>:/opt/plant_metrics:rw` gives CLEAVE access to the recently created `~/results/<experiment_name>` directory.
      All data files from the experiment will be output here.
   2. `-e CONTROLLER_ADDRESS=$(dig +short <region>)` tells CLEAVE to use the controller on device `<region>`.
   3. All other values preceding by the `-e` flag correspond to tweakable parameters of CLEAVE; these are the ones we will use to experiment.
      The values given above correspond to the defaults for these parameters.

4. Switch back to the Jupyter Server webpage you have open on your local computer and re-run the `analysis.ipynb` notebook by clicking on the double-arrows on the toolbar.
5. Analyze the results.


### Experiment 1

1. Deploy the CLEAVE controller on `eu-central-1`.
   This corresponds to a datacenter in Frankfurt.
2. Execute the CLEAVE plant with the following parameters:
   - `-v ~/results/eu-central_len0.5_srate20:/opt/plant_metrics:rw` (remember, you will have to create the `~/results/eu-central_len0.5_srate20` directory beforehand).
   - `-e CONTROLLER_ADDRESS=$(dig +short eu-central-1)`
   - `-e TICK_RATE=120`
   - `-e SAMPLE_RATE=20`
   - `-e EMU_DURATION=30s`
   - `-e PEND_LEN=0.5`
4. Analyze the results. Is the plant stable?
5. Now repeat the experiment, setting
   - `-v ~/results/eu-central_len1.0_srate20:/opt/plant_metrics:rw` (you will have to create
     the `~/results/eu-central_len1.0_srate20` directory beforehand).
   - `-e PEND_LEN=1.0`
   
   Is the plant stable?
6. Now set `PEND_LEN=0.5` again, and instead set `SAMPLE_RATE=120` (remember to create the appropriate result directory `~/results/eu-central_len0.5_srate120` and mount it using the `-v` option).
   How do pendulum length and sampling rate interact in relation to plant stability?

### Experiment 2

1. Deploy the CLEAVE controller on `eu-north-1`.
   This corresponds to a datacenter in Stockholm.
2. Repeat the same setups as for [Experiment 1](#experiment-1).
   Again, remember to create appropriate directories and mount them using the `-v` option; also, remember to point CLEAVE to the correct host with `-e CONTROLLER_ADDRESS=$(dig +short eu-north-1)`.
3. Analyze the results.
   How does the system stability of the scenarios on `eu-north-1` compare to those on `eu-west-1`?
4. Now, set `PEND_LEN=0.5`, and try with `SAMPLE_RATE` values of 20, 30, 40, and 60Hz (once again, remember the directories).
   At which point does the system become stable?
   What does this tell us about latency and system stability?

### Bonus Round

Repeat the above experiments, but deploying a controller on `us-east-1`.
Is there any way of making the plant stable?