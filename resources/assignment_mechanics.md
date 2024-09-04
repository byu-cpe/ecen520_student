# ECEN 520 Assignment Mechanics

This page describes the mechanics of completing assignments including how to submit your assignments for the class. 

## GitHub

All assignments for this class will involve committing report files and source code to a private GitHub repository.
If you do not have a GitHub account, you will need to [create an account](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F&source=header-home) for use in this class.
<!--
Send me your github username so I can add you as a user on the [ECEN_520](https://github.com/byu-cpe/ECEN_520) github repository which contains course materials, the class wiki, and assignment descriptions.
-->
It is essential that you become proficient with using Git and GitHub for this class.
You will be responsible for learning how to use 'git' and 'GitHub' for creating repositories, committing code, managing Markdown files, and maintaining your projects. 
If you are not familiar with using these tools you are encouraged to complete the BYU bootcamp tutorials for [git](https://byu-cpe.github.io/ComputingBootCamp/tutorials/git/) and [GitHub](https://byu-cpe.github.io/ComputingBootCamp/tutorials/github/). 
There are many other tutorials online you can follow to sharpen your git/GitHub skills.

You will need to create a custom repository for this class that includes startercode to help you get started.
The instructions for creating this repository are described in the [Setting up your GitHub Repository](#setting-up-your-github-repository) section below.

## Generative AI & GPTs

Generative AI tools like chatbots and Co-Pilot can be helpful in completing assignments.
You are welcome to use co-pilot within VSCode to help you write your HDL code but you are strongly encouraged to type the code in yourself until you are comfortable with the syntax and structure of the code.
You will be responsible for understanding the syntax and structure of SystemVerilog (and the other languages we use in this class) and you will be tested on this knowledge in the exams.
If you rely exclusively on Co-Pilot to write your code you will likely not understand the syntax as well as you should for exams and for designing on your own.

I have created a custom chatbot for this class that is accessible at the following URL: [https://ecen-digital-tutor.byu.edu/](https://ecen-digital-tutor.byu.edu/).
This chatbot is based on OpenAI's 4.0 large language model but has been modified to provide specific help in completing these lab assignments.
Specifically, this chatbot will be trained with improved answers to questions about the assignments and has access to the reference manuals for the tools we use in this class.
This chatbot will be constantly updated and trained throughout the semester to improve the learning environment for the class.

For this class I would like you to use this chatbot to help you with your assignments and **NOT** to use other chatbots to complete the assignments.
If you feel that the class chatbot is insufficient, please contact me to help me improve it.

## Assignment Reports

Every assignment will require you to submit a report.
This report is submitted as a markdown file named `report.md` in your assignment submission directory.
A [template report](./report_template.md) file has been created for you.
You need to customize this for each assignment and include it with your repository as part of your submission.

For each assignment you will need to keep track of the number of hours you spent on the assignment.
This helps me gauge the difficulty of the assignment and see how long it takes for you to complete it.
There is a section on each report for you to enter the number of hours you spent on the assignment.

I would also like you to summarize any major challenges you faced in the lab to give me a better idea on how I can improve the assignment in the future.
Each assignment will also ask you to list a few of the major challenges you faced during the assignment.
Each assignment report template will also provide several questions specific for that assignment.

## Assignment Files

Your assignment submission will involve adding a variety of files into your repository as described in the assignment instructions.
More details on what files are needed will be included in the instructions of each assignment.
These files will be reviewed as part of your assignment grade. 
You will be required to follow several [Git repository standards](./coding_standard#git_repository_standards) as you maintain your repository and your assignment grade will be based in part on how these standards are followed.

## Makefiles

You will be required to create a custom `makefile` for each assignment that allows you and me to build your assignment from the command line.
The details on the makefile rules needed for each assignment will be described on the assignment summary page.
All assignment makefiles must have a `clean` rule that will completely clean all intermediate files generated by project.
You will lose points on your assignment if you fail to clean all intermediate files generated by your project.

## Assignment Submission Process

An assignment "submission" involves a final commit and tag of files to your class repository. 
The assignment due dates are posted on learning suite. 
Each assignment submission will require a unique 'tag' where the actual tag is the same as the directory for the assignment.
When grading your assignment, I will check the submission time of this tag. 
If your latest commit of any file in the assignment with this tag is later than the deadline then you will be penalized for being late.
You may change your files after the submission date but do not retag these files unless you are changing your submission.
A [submission process checklist](#assignment-submission-checklist) has been created for you to review as you submit your assignments.

## Assignment Due Dates and Late Policy

Each assignment will have a due date/time published on learning suite.
It is your responsibility to identify the due date and submit your assignment on time.
Late assignments will be accepted and graded but will be subject to a 20% penalty.
Late submissions can be submitted at any time but late submissions will not be graded in a timely manner and may not receive any feedback.
**No credit will be given for any assignments submitted after midnight on the last day of class (December 11th).**

## GitHub Commits

For this class you are required to submit regular commits to your repository as you complete your assignments.
When using Git, you typically commit your code when you have something working to checkpoint your progress.
In this class we will use Git more aggressively by having you commit your code *when you encounter a problem*.
This way I can track your progress through the assignment and see the problems you ran into.
These commits will help me improve the labs and provide better feedback.
Further, I plan on using your commit history as part of a training set for a machine learning project I am working on (this project will collect examples of "non working" HDL code, the error messages that were generated, and the fixes that were made to get the code working).

When committing your code after you experience a problem add a commit message with the following form: `"ERR:<error code> <Error summary>"`.
This message is needed for me to review the various types of errors you are experiencing and see how you resolve the problem.
The following error codes should be used:
* VLOG: An error with the QuestaSim module compilation. Use this error code for VHDL errors as well (the VCOM tool in QuestaSim)
* SIM: An error when trying to run the vsim simulation tool. Note that this code should not be used when your module simulates but operates incorrectly. This is for errors in the elaboration process before starting the vsim simulation.
* TEST: When your module fails a simulation testbench
* SYNTH: An error with the synthesis process (`synth_design`)
* IMPL: An error during the implementation process (`opt_design`, `place_design`, `route_design`, or `write_bitstream`)
* DOWNLOAD: When your bitstream that is downloaded does not operate properly

For example, the following commit message demonstrates the proper way to describe a synthesis error: `"ERR:SYNTH There was a combinational feedback loop in my design"`.

You are encouraged to commit regularly when your code reaches various stable states of working.
Each assignment will require you to include a certain number of these error commit messages.

# Assignment Submission and Grading

## Assignment Submission Checklist

Proper submissions of assignments is an involved process that must be followed carefully.
This section provides a brief summary checklist of what you need to do to submit your assignment.

1. Merge your repository with the latest starter code to make sure you have the latest starter code before submission.
1. Make sure all assignment specific "makefile" rules are implemented and are working.
    * The required makefile rules for each assignment will be summarized in the assignment instructions. You are welcome to include any others you like.
    * You will not get any credit for the assignment if any of your makefile rules fail.
2. Make sure all the _essential_ files needed to complete your project are committed into your repository.
    * If any essential files are missing then your make rules will likely fail and you will not get any credit for the assignment.
3. Make sure no _non-essential_ files are **NOT** committed to your repository
    * It is possible to inadvertently commit temporary project files.
    * You will lose significant points if you commit large number of non-essential temporary files.
4. Make sure you have a `.gitignore` file for your assignment directory and that all intermediate files created during the build process are ignored.
    * You will lose points if intermediate files are generated by your make rule and are not ignored by your `.gitignore` file.
5. Make sure you have a `make clean` rule that cleans _all_ intermediate files generated by your project.
    * This rule needs to clean these files even if they are ignored
    * You will lose points if your `make clean` rule does not clean all intermediate files.
6. Each assignment will have a test script named `assignment_check.py` that will run all your rules and check your repository for compliance as described above. Run this script and clean up any problems that this script may identify.
7. Copy the template [report](../resources/report_template.md) file into your assignment directory and name it `report.md`. 
    * Complete the required sections of the report.
    * Complete any assignment specific responses in the report. These will be listed in the assignment instructions.
8. Commit, tag, and push your repository with the predetermined assignment tag.

Each assignment has a `assignment_check.py` script that you can run to check your repository for compliance with the assignment requirements.

## Assignment Grading Checklist

This section provides a brief summary of how your assignment will be graded.
I will run these commands on the digital lab computers using the software installed on those computers.

1. Fetch and get tag of your submission
```
git fetch --all --tags
git pull
git checkout tags/<assignment tag>
```
2. Check date of submission and compare with the due date
```
git log -n 1 tags/<assignment tag>
```
3. Run the assignment test script (for example, `python3 assignment_check.py --noclean`) without running the clean step
   * review the logs for any warnings and errors
4. Review products of the build script
    * Download any bitstreams and run them on the FPGA board
    * Review the synthesis/implementation logs
3. Run the test script again with 'clean' and review the logs for any warnings and errors
4. Review and grade the `report.md` file and the assignment specific responses
5. Review the code for coding standard compliance

<!--
7. Check to see if there are any files that are generated during the build process but not ignored. I will run the following command:
`git ls-files . --exclude-standard --others`. <br>If there are any files not ignored after running the above make commands then you will lose points.
7. Review the number of commits and the commit messages to your assignment directory: `git log --pretty=format:"%ad %s" --date=short --`. You will need to demonstrate that you have made several error commits as part of your history. `git log --pretty=format:"%ad %s" --date=format:"%m%d%y/%H:%M"`
8. run `make clean`
I will clean the directory where I ran your commands to make sure the clean works properly. 
I will check to see if your `make clean` cleaned all the ignore files: `git check-ignore *` <br>
If there are any files that remain that are not cleaned by the `make clean` then you will lose some points.
10. Review your Readme.md to see if it has all the requirements
11. Review your code for compliance to the coding standards

-->

## Assignment Grading

Each assignment will be graded using the following three components:
* **Operation** of your final assignment 
* **Coding Standard** of your submission
* **Assignment specific criteria**
The actual allocation of the assignment grade will be specified in the assignment page.
Each of these will be described in more detail below.

**Operation**

For this portion of your grade, you will be graded on the actual functionality of submission and will depend on the requirements of the given assignment.
This will usually include a simulation, synthesis, and actual operation on an FPGA board.
Note that submissions that do not simulate or build (i.e., submissions with syntax or build errors) will not receive any credit for this component of your grade.

**Coding Standard**

All of your submissions should conform to the class [coding standards](./coding_stadard.md).
The coding standards are progressive meaning that additional standards will be added gradually throughout the class.
Each assignment will indicate which code standard level you will be required to follow.

In addition to following coding standards, you are required to follow several git repository organization [standards](./coding_stadard.md#git-repository-standards).
Several basic standards for organizing your github repositories are given to aid in the grading of assignments and to provide a tidy repository environment.

You will receive full credit for this portion of your assignment grading if you conform to the coding and repository standards.
You will receive feedback for any violations of these standards as part of your assignment grade.

**Assignment Specific Criteria**

This portion of your grade will be based on any assignment specific criteria you are given.
See the assignment description for details on this portion of your grade.

# Setting up your GitHub Repository

These instructions summarize how to setup your GitHub repository for this class.

## GitHub Classroom Repository

You will need to create a GitHub classroom repository for this class.
Visit the following [URL](https://classroom.github.com/a/NLOnd6Wh) to create your classroom repository.
I will have access to your repository for grading purposes.

<!--
Create a private personal repository for this class. 
Name this repository "ECEN_520_\<last name\>" where \<last name\> refers to your last name using conventional capitalization (i.e. `Wirthlin` for my last name).
Make sure the repository is private. 
After creating the repository, [add me as a collaborator](https://docs.github.com/en/github/setting-up-and-managing-your-github-user-account/managing-access-to-your-personal-repositories/inviting-collaborators-to-a-personal-repository) to the repository. 
My GitHub username is `wirthlin`. 
-->

## ECEN 520 Student Template Code

The [ECEN 520 student repository](https://github.com/byu-cpe/ecen520_student) is a repository that contains all the template code you need to complete the assignemnts for this class.
You will need to populate your classroom repository with this repository to get started on your assignments.
The following commands will clone the student repository and push it to your classroom repository (make sure to change your github username):
```
git clone --bare git@github.com:byu-cpe/ecen520_student.git
cd ecen520_student.git/
git push --mirror git@github.com:byu-ecen520-fall2024/520-assignments-<githubusername>.git
cd ..
rm -rf ecen520_student.git
```
More details on this process can be found at Step 3 of the [ECEN 323 web page](https://byu-cpe.github.io/ecen323/tutorials/git_setup/).

At this point you should have a remote repository that contains all the starter code for the class.

### Creating a Local Repository

Once you have a remote repository that is properly populated with the starter code, you will need to clone this repository to your local machine.
Complete the following steps every time you create a local repository for an assignment:
```
# Clone your repository
git clone git@github.com:byu-ecen520-fall2024/520-assignments-<githubusername>.git ~/ecen520
# Create a remote repository to the starter code
cd ~/ecen520
git remote add startercode git@github.com:byu-cpe/ecen520_student.git
```
<!-- https://github.com/byu-cpe/ecen520_student -->


See Steps 4-5 of the [ECEN 323 web page](https://byu-cpe.github.io/ecen323/tutorials/git_setup/) for more details of this process.


### Updating Your Starter Code

The class starter code will be continually updated throughout the semester.
You are responsible for updating your local repository with the latest starter code.
You should do this before starting each assignment as well as before submitting your assignment to make sure you have the latest starter code.
The steps for updating your starter code are as follows:
```
git fetch startercode
git merge startercode/main -m "Merging starter code"
```
