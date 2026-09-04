# ECEN 520 Tools

These instructions describe how to access and run the tools we will be using for the class.

## Department Computers

The tools used in this class are installed in the digital lab (EB 423) and the embedded systems lab (EB 438).
You can access these computers in person or remotely with your CAEDM account.

These labs can be very busy during the semester and many hours during the week are reserved for other classes, so please plan accordingly.
Check the [lab schedule](https://ecelabschedule.byu.edu/) to see when each lab is open.
You should **not** use the labs during closed lab sessions.
You may use the lab during "overflow" sessions but you may need to give up your seat if the lab fills up with students from the class that has reserved the lab.

### Digital Lab Computers

There are 61 computers in the digital lab (room EB 423) ([EB 423 schedule](https://ecelabschedule.byu.edu/#eb-423)).
These computers can be accessed as `digital-XX.et.byu.edu` where `XX` is the number of the computer
(Note that the number is two digits, so computer 1 is `digital-01.et.byu.edu`).
Computers 1-60 are student stations and computer 61 is the TA station in the back.

### Embedded Lab Computers

There are 24 computers in the embedded lab (room EB 438).
These computers can be accessed as `embed-XX.ee.byu.edu` where `XX` is the number of the computer (note that the number is two digits, so computer 1 is `embed-01.ee.byu.edu`).

### Nexys4 DDR Boards

The Nexys4 DDR boards are available on select computers in the embedded lab (EB 438).

## Xilinx Vivado

1. Source the following file to set up the environment for Vivado: ```source  /tools/Xilinx/Vivado/2024.1/settings64.sh```
2. You can tell if it is setup properly by running the following command: ```vivado -version```

## QuestaSim
<!--
Modelsim version 10
https://faculty-web.msoe.edu/johnsontimoj/Common/FILES/modelsim_user.pdf
Command reference version 5
https://web.eecs.utk.edu/~dbouldin/protected/modelsim_se_ref.pdf
-->

### QuestaSim Setup 
1. Add the following lines to your .bashrc or a startup script.
```
export PATH=$PATH:/tools/questasim/bin
export LM_LICENSE_FILE=1717@ece-modelsim.byu.edu
```
2. You can tell if questasim is setup properly by running the following command: ```vsim -version```
