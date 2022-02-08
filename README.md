# PECA Classroom Day Feb 10 2022 Exercises

## Preparations

1. Before starting the exercises, download this repository to your computer.
You can do so by clicking the green `Code` button above and selecting `Download Zip`.

2. Next, extract the contents of the archive somewhere, then open a terminal (Linux/MacOS) or command prompt/PowerShell (Windows) window and navigate to this folder.

3. Use the command `python3 -m virtualenv ./venv` to initialize a Python virtual environment.

4. Activate the virtual environment with the command `source venv/bin/activate`.

5. Install the necessary Python packages with `pip install -Ur requirements.txt`.

6. Finally, initialize the Jupyter server we will be using for interactive analysis of the data: `jupyter lab`. 
   Once Jupyter has started, you can reach it by clicking on the link which will be printed on the terminal.
   Do not close this terminal window until the end of the session.

For example, here's what the whole procedure would look like on Linux/Mac OS, assuming the archive was extracted to `~/Downloads/peca2022`:

```bash
$ cd ~/Downloads/peca22

$ python3 -m virtualenv ./venv

$ source venv/bin/activate

(venv) $ pip install -Ur requirements.txt

(venv)  $ jupyter lab
```

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
    

## Exercises

### RTT Measurements

The virtual machine you have been assigned is connecte to a number of other machines in different regions of the world: Sweden (eu-north-1), Ireland (eu-west-1), and US East Coast (us-east-1).
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

2. Make a directory to collect the results: `mkdir result_dir`.

3. Run the plant locally, pointing it to a controller on `<region>`:

  ``` bash
  docker run --rm -it --network host \
      -v result_dir:/opt/plant_metrics:rw \
      -e CONTROLLER_ADDR=<region> \
      -e CONTROLLER_PORT=50000 \
      -e TICK_RATE=120 \
      -e SAMPLE_RATE=20 \
      -e EMU_DURATION=30s \
      -e PEND_MASS=0.2 \
      -e PEND_LEN=1.2 \
      molguin/cleave:cleave -vvvv run-plant \
      examples/inverted_pendulum/plant/config.py
  ```

  In the above command, each value preceded by `-e` corresponds to a tweakable parameter; these are the ones we will use to experiment.
  The values given above correspond to the default values for these parameters.
  Additionally, the `-v` flag allows us to extract results from the container; note how we use it to allow CLEAVE to access the `result_dir` we previously created.
  
4. Transfer the results to your local computer, for instance using `scp`: `scp <ip address>:/path/to/result_dir ./results.`

5. Move the `result_dir` to the `experiments` folder of this repository.

6. Head to the Jupyter Lab web page we prepared in the preliminary stage of these exercises, and open the `analysis.ipynb` Jupyter Notebook.

7. Modify the necessary variables at the top of the notebook according to the parametrization of the current experiment, then run the notebook by clicking on the double green arrows in the toolbar.

8. Analyze the results.


### Experiment 1

1. Deploy the CLEAVE controller on `eu-central-1`.
   This corresponds to a datacenter in Frankfurt.
2. Execute the CLEAVE plant with the following parameters:
   `TICK_RATE=120`, `SAMPLE_RATE=20`, `EMU_DURATION=30s`, and `PEND_LEN=0.5`
3. Analyze the results. Is the plant stable?
4. Now repeat the experiment, setting `PEND_LEN=1.0`. 
   Is the plant stable?
5. Now set `PEND_LEN=0.5` again, and instead set `SAMPLE_RATE=120`.
   How do pendulum length and sampling rate interact in relation to plant stability?

### Experiment 2

1. Deploy the CLEAVE controller on `eu-north-1`.
   This corresponds to a datacenter in Stockholm.
2. Repeat the same setups as for [Experiment 1](#experiment-1).
3. Analyze the results.
   How does the system stability of the scenarios on `eu-north-1` compare to those on `eu-west-1`?
4. Now, set `PEND_LEN=0.5`, and try with `SAMPLE_RATE` values of 20, 30, 40, and 60Hz.
   At which point does the system become stable?
   What does this tell us about latency and system stability?
