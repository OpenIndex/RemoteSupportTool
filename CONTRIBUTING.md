# Contributing


## Notes about branches

This project follows the principles of the [GitFlow branching model](http://jeffkreeftmeijer.com/2010/why-arent-you-using-git-flow/) as [proposed by Vincent Driessen](http://nvie.com/posts/a-successful-git-branching-model/). According to this model you will find these branches at the GitHub project page:

-   The [master branch](https://github.com/OpenIndex/RemoteSupportTool/tree/master) contains the current stable releases. No development is directly taking place in that branch.
     
-   The [develop branch](https://github.com/OpenIndex/RemoteSupportTool/tree/develop) represents the current state of development. Changes from this branch are merged into [master](https://github.com/OpenIndex/RemoteSupportTool/tree/master) when a new version is released.
    
-   For more complex features you may also find different feature branches. These are derived from [develop branch](https://github.com/OpenIndex/RemoteSupportTool/tree/develop) and are merged back / removed as soon as the feature is ready for release.

> **Notice:** If you like to provide changes to this project, you should always use the [develop branch](https://github.com/OpenIndex/RemoteSupportTool/tree/develop) as basis for your customization. Feel free to create separate feature branches for any custom feature you like to share. 


## Create a pull request

We love pull requests. Here's a quick guide.

-   Fork this project into you GitHub profile.

-   Clone the [develop branch](https://github.com/OpenIndex/RemoteSupportTool/tree/develop) of the repository to your 
    local disk:
    ```
    git clone -b develop git@github.com:your-username/RemoteSupportTool.git
    ```
    
-   Do your changes to the local repository and push the changes back into your fork at GitHub.
 
-   [Submit a pull request](https://github.com/OpenIndex/RemoteSupportTool/compare/) with the changes from your fork.

At this point you're waiting on us. We like to comment on pull requests as soon as possible. We may suggest some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted:

-   Test your changes.

-   Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
