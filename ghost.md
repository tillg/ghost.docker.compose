# Ghost 

## Backing up ghost

To back up a ghost installation we follow these steps:

* The **content** is backed up by using the Ghost export functionality (under the _Labs_ area in the admin interface). This creates a JSON file witzh all the content - except the images.
* Copy the **image folder** to your backup location. The image folder is located in `ghost/images/`.

## Filling an empty ghost

A guide to fill up a ghost instance with data from a backup. 

* The **starting point** is a freshly installed ghost instance. By pointing your browser to this instance, you would see the default ghost start page. let's call it https://my-blog.com
* With your browser go to the admin page, that would be https://my-blog.com/ghost and wlak throu the setup process. Make sure the admin user you create is bound to the same email address as the Admin user of the ghost site you want to import.
* **Delete all** existing blog entries via the Labs area
* **Import the backup** in the Labs area. You would expect at least one warning that a user could not have been installed sue to a duplicate entry: That's the Admin user you created...If you have a look at your site now, you should see the content without the pictures.
* Make sure the proper **Theme** is chosen / uploaded / active. - Do we really need this, or it it may be already covered by importing the backup json?
* Upload the **`routes.yml`** - Do we really need this, or it it may be already covered by importing the backup json?
* Copy over the **images folder** from the backup. If you are in the directory that holds the backup the command could be something along those lines: ` scp -r ./images/* ubuntu@my-blog.com:/opt/docker/ghost/ghost_content/images/`

The following aspects need to be checked:

* Is the theme set by importing the json file?
* Are the routes set by importing the json file?
* Are the other users created properly?
* How do we migrate from one ghost version to another?

## Scripted backup/restore procedures

