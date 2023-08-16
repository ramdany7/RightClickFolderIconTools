# RCFI TOOLS
Adds "Folder Icon Tools" to your right-click menus, allowing you to easily customize folder icons with a simple right-click. 

|![](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/683be449-8e14-4f2f-aecc-6d0311d9c05c) Folder Right-click ![RCFI-Folder_Menu](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/8703384d-3c81-45fc-87cb-befa5891718c)|![](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/683be449-8e14-4f2f-aecc-6d0311d9c05c) Background Right-click ![RCFI-Background_Menu](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/253aea77-5c6d-4fdd-bbf7-4819cf2270a8)|![](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/683be449-8e14-4f2f-aecc-6d0311d9c05c) Image Right-click ![RCFI-Image_Menu](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/52230ba6-cee8-4bf7-903b-6e5751acc207)|
|     :---      |     :---      |     :---      |

<br><br>

# Installation
- Download the .zip file **here** (not available yet).
- Extract the downloaded file.
- Run "RCFI Tools" and click "Yes" when prompted.
- Done! "Folder Icon Tools" can now be accessed from your right-click menus in Explorer.

<br><br>

# Features
- Set images as folder icons directly by right-clicking on them.
- Use keywords to automatically set the matched file inside a folder as the folder icon.
- Supports a wide range of image extensions (`*.jpg`, `*.png`, `*.ico`, `*.webp`, `*.jpeg`, `*.bmp`, `*.tiff`, `*.heic`, `*.heif`, `*.wbmp`, `*.tga`, `*.svg`).
- Automatically edits, converts, and sets images as folder icons.
- Provides several available templates to choose from, eliminating the need for manual editing.
- Achieve everything with just a few clicks, making it easy and fast.

<br><br>

# Usage
It's simple and easy to use. Once installed, you can generate a folder icon by right-clicking on a folder, an image, or the folder background.
You can choose the template you want to generate the folder icon, it will automatically edit the image using ImageMagick. 
<br><br>
Here's some samples of the template i've made.

<br>
<b>      Folder and addtional files.</b>
 
|Folder<br> ![Folder](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/b2ab9d18-9faa-47e6-ab7f-bfc7d1aadf11)|Files inside the folder<br> ![Files](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/e0c20a52-5caf-4ec6-abc8-34d5122191e5)|
|     :---      |     :---      |
<br>
<b>      Generated icon using default template settings.</b>

|![(none)](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/832f2530-6b3b-41e9-a80a-692bc52e6ebd)<br>(none)          |![(Shadow Only)](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/13045086-4646-44a0-84a2-3ef957d923e0)<br>(Shadow Only)          |![DVDBox Dark](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/119e02b0-db45-401a-8ada-c2ea41033611)<br>DVDBox Dark          |![DVDBox Light](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/95a30678-84ed-4e27-9d64-02f4a72f87b5)<br>DVDBox Light          |
|     :---:      |     :---:      |     :---:      |     :---:      |
![DVDCase - Bluray](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/540689b7-c957-4b4b-9414-6e507cd14f44)<br>DVDCase Bluray          |![DVDCase - Transparent Plastic](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/76aa86f8-9c1d-4572-abf9-2bba66929810)<br>DVDCase Plastic          |![Folder Vertical](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/8e27620d-824c-4c7b-8126-f87deff44d4f)<br>Folder Vertical          |![Folder Horizontal](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/dca6ae78-3db5-43f9-8d5f-1e4bdb049403)<br>Folder Horizontal          |
<br>

>_The samples above use the `*Poster*.jpg` image as the folder icon, some templates with certain configuration may combine additional files located within the same directory as the image to get the results as shown above._<br>
<br>

To give you an idea of how it looks and how you can use it,<br>
I've made a video that you can watch it ![**Here**](https://www.youtube.com/watch?v=MT7BZlhRWfI).<br>
[![Youtube](https://github.com/ramdany7/RightClickFolderIconTools/assets/113004105/86f4ecdb-d141-4ce6-893f-e08031796113)](https://www.youtube.com/watch?v=MT7BZlhRWfI)

<br><br>

# Configurations
###      Template Configuration
Some templates include configuration settings that can be customized according to your preferences. To modify the configuration, open the 'template file.bat' using a text editor and adjust the values. The 'template file.bat' can be found at `RCFI Tools\template\`.

Here are the available settings:
|Configuration|Options|Description|
|   :---   |   :---   |   :---   |
|set "display-movieinfo= "                    |`yes` `no`            | Search for a '***.nfo**' file located within the same directory as the selected image to get movie information.|
|set "show-Rating= "                          |`yes` `no`            | Show movie's rating on generated folder icon|
|set "show-Genre= "                           |`yes` `no`            | Show movie's genre on generated folder icon|
|set "genre-characters-limit= "               |[number]              | Limit the movie's genre characters to fit the template.|
|set "display-FolderName= "                   |`yes` `no`            | Display folder name on the generated folder icon|
|set "FolderNameShort-characters-limit= "     |[number]              | Limit the folder name characters to fit the template.|
|set "FolderNameLong-characters-limit= "      |[number]              | Limit the folder name characters to fit the template.|
|set "FolderName-Center= "                    |`yes` `no` `Auto`     | Align the folder name label on the generated folder icon to the left, center, or use auto-adjustment based on character count.|
|set "use-Logo-instead-FolderName= "          |`yes` `no`            | Search for '***Logo.png**' within the same directory as the selected image and place it in the folder name's position.|
|set "display-clearArt= "                     |`yes` `no`            | Search for '***ClearArt.png**' within the same directory as the selected image and place it on the generated folder icon.|
|set "display-discimage= "                    |`yes` `no`            | Search for '***DiscArt.png**' within the same directory as the selected image and place it on the generated folder icon.|

>Note: The availability of the above settings may vary depending on each template.<br>
>You can also create your own template using a batch script, just place the script within the 'template' folder.

<br>

###      RCFI Tools Configuration
The RCFI Tools Configuration can be found in `RCFI Tools\config.ini` and can be adjusted and modified using a text editor.

Here are the available configuration options:

|Configuration|Options|Description|
|   :---   |   :---   |   :---   |
| DrivePath=" "                         |[none]                        | Last used drive path |
| Keyword=" "                           |[string]                      | Keyword for searching an image to set as the folder icon|
| Keyword-Extension=" "                 |[image file extension]        | File extension to search for the image|
| Template=" "                          |[template file name]          | Default template to use for generating folder icon|
| TemplateForICO=" "                    |[template file name]          | Template to use if the image extension is .ico|
| TemplateForPNG=" "                    |[template file name]          | Template to use if the image extension is .png|
| TemplateForJPG=" "                    |[template file name]          | Template to use if the image extension is .jpg or .jpeg|
| TemplateAlwaysAsk=" "                 |`yes` `no`                    | Always ask which template to use for generating the folder icon|
| TemplateTestMode=" "                  |`yes` `no`                    | When selecting template via choose template menu, redirect to Test Mode page to generate folder icon and execute the template|
| TemplateTestMode-AutoExecute=" "      |`yes` `no`                    | Generate folder icon and automatically execute the template when modifications on the template file detected|
| TemplateIconSize=" "                  |[icon height]                 | Specifies the icon height to be generated; multiple icon sizes can be specified, e.g., `256,192,64`, which will create icon files with `256x256px`, `192x192px`, and `64x64px` icon resources.|
| ExitWait=" "                          |[number]                      | Automatically closes the window after [number] seconds. If the number is greater than 99, it will pause indefinitely until manually closed.|


<br><br>

# Credits
_In the end, I'm just an average person on the internet. My role involves is just bringing together the work and ideas of others to bring this project to happed. <br>_

- This project was inspired by ![Anime Icon Matcher 2018](http://www.mediafire.com/?nv3m231s8h9be) by serenity !29TgfcZgPU, which I used a lots in the past.
- This project owes its existence to ![ImageMagick](https://github.com/ImageMagick/ImageMagick), the tool that is use to process and edit images.
- I utilize the ![SingleInstanceAccumulator](https://github.com/Beej126/SingleInstanceAccumulator) by Beej126 to accumulate the selected items in Explorer so it doesn't make a new instance for each selected items.
- I use PSD templates by ![em1l](https://www.deviantart.com/em1l), ![saikuro](https://www.deviantart.com/saikuro), ![mauricioestrella](https://www.deviantart.com/mauricioestrella) and ![90scomics.com](http://www.90scomics.com) to create all available folder icon templates.
- While working on this project, I also drew some inspiration from ![FolderIco](http://folderico.com) and ![Raticon](http://jamedjo.github.io/Raticon) by Jamedjo.<br>

**_A big thank you to all mentioned above for their contributions._**
