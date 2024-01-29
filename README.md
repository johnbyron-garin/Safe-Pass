# CMSC 23 Project

## Group Details
Section: B-3L

Contributors: Caponpon, Ludovico, Laron, Garin

## Program Description
A health monitoring app that lets authenticated users (student, admin, entrance-monitor) add a health entry every day. 

Moreover, an Admin can elevate student's account type, and modify a user's status (cleared, under monitoring, under quarantine). While an Entrance Monitor can view building logs.  

## Installation Guide
Download the app through this link (https://drive.google.com/drive/folders/1zc2Na6QGSHiziyjI0o3FWjJyMEg4vuyA?usp=sharing). 

## How to Use
1. A user needs to login in order to access the app. A signup option is given if user has no account.

2. The app's features vary depending on the account type of the user who logged in. They can navigate the app through the side drawer, but the general usage for all users is to add today's entry, and view their entry history.

3. To add an entry, press on the floatingActionButton on the home screen. This will redirect you to a form. Select all that apply, and press on the Submit button.

4. A building pass will be automatically generated if the user has no symptoms and covid case encounter. Otherwise, having symptoms will put you under quarantine, and having a covid case encounter will put you under monitoring.

5. A user can only add one entry everyday, but can request to edit/delete their entry (needs admin approval).

## MILESTONES

#### Milestone 3
Features:
1. Navigation Menu (drawer) screen 
![ss1 0](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/3a2640dd-2f74-482a-8fcd-a78193f0c3b9)

2. 'AddEntry' screen 
- has an entry today
![ss2 1](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/e7aa6ae2-5572-45a2-bc35-94dfc445d0fa)

- no entry for today
![ss2 2](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/b5dbe61b-1a2c-4320-966e-fa3972f407df)

    Upon form submission, show 'GenerateBuildingPass' screen
    a) If no symptoms and infected person encounter, generate qr
    b) Else if quarantined/under monitoring, monitoring/quarantined
  
3. Today's Entry
- no entry for today 
![3 1](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/aeac341b-09e4-4210-a516-07b737698be4)

- has an entry today
![3 2](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/f8317bd9-6a44-4f64-847d-4057865b6b57)

    a) Can delete entry
    b) Can edit entry 
    ![3 2a](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/35a6a641-93e3-49bf-b8f6-b2c10dbf8fdb)

    
4. Profile screen
![ss4 0](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/40e0c675-ac1b-4a00-8936-434af7370c53)

- 'UserInformation' screen
![ss4 1](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/00635f06-91c5-4c67-9711-04ffec550891)

- 'GenerateBuildingPass' screen
![ss4 2](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/d1736656-bdb3-4a2b-b3a9-8273e8ba1d96)

- 'EntryHistory'screen
![ss4 3](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/75f36a99-e6f9-4edf-98b5-d1ac9717f57a)

5. Created models for each firestore database: account, entry, entry_request

#### Milestone 2
Features:
1. Created a separate screen for Pre existing illnesses (to make student sign up page not convoluted). (please fix spelling)
![sc2 1](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/20ea733a-1e58-4f4e-937e-dc73c531a06d)

2. Created a separate screen for distinguishing the type of user for sign up.
![sc2 2](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/caa0d4d0-6050-4d69-9570-ef5b6b472d81)

3. Created a sign up form for non-student.

![sc2 3](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/20eb0f77-27a3-470d-88ab-c194718401fd)

4. Created a completed screen mock up in Figma.
![sc2 4](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/58c18fff-b34d-439a-92af-7e5c212989e9)

---

#### Milestone 1
Feature/s: 
1. Account Sign-up page - Allows users to create an account.
2. Connected Firebase authentication, and  firestore-database - Authenticates a user's login credentials and stores important user information in the database.

To implement:
1. Sign-up for Admin and via Entrance Monitor
2. Login for User, Admin, and via Entrance Monitor

Screen upon running the app: welcome 
![sc01](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/64ec849b-e63d-48e7-b182-420f917072ca)

Screen upon pressing Sign Up btn: signup
![sc02](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/557c2b1e-b850-4746-a9ce-461f79e0c166)

Initial firebase (with dummy data):
![sc04](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/4dafd6fa-ab9c-4c78-91e5-23a13a6e7722)

Firebase if account sign up is successful:
![sc06](https://github.com/CMSC-23-2nd-Sem-2022-2023/cmsc-23-b-3l-project-23-b3l-group-5/assets/90666815/4bdd0418-b7d5-4b98-b4d3-5727321739ea)

