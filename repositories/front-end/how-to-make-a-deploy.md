# How to make a new deploy

On the the firebase console got to the [project](https://console.firebase.google.com/u/0/project/tpb-kiosk-fe-vue/overview), and follow this steps:

* Go to **hosting**  then **add another site** 
* write the name of the hosting/site you want to deploy 
* click on **add site**

On your local project

  - Make sure your login with an account that has the access to the project and your currently using the firebase project.
    - Run **firebase use** to verify you are on right project 
  - Go to the **.firebaserc** file located on the root of the project, inside the projects object, add a new property as an indetifier for the deploy, the value should be the same as the default property
  - Inside **firebase.json** file on the root of the project, inside the hosting arrays add a new item to the array, **copy and paste** on of the prexisting items and change the **target** property on the item to the name of the hosting your previosly created on firebase.
  
  - run the following command  
    ```bash 
    firebase target:apply hosting <indefier on .firebaserc> <hosting added on firebase>
    ```

to deploy changes to the hosting 

  - Build your current project by running ```
npm run build```

  - **important** : do not create a **commit** with this build if you are not on master branch, this will add many changes and it will be hard to track the significant ones on a PR
  - once the project has build successfuly run the follwing command
    ```node 
      firebase deploy --only hosting:<indentifier added on .firebaserc>
    ```
     
once deployed the change shoul apear on the url of the hosting.