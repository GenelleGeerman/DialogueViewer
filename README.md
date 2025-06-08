# DialogueViewer

DialogueViewer is a Godot plugin designed to help non-programmers visualize and manage dialogue interactions through a user-friendly menu—without touching code. This tool is perfect for narrative-driven games or any project that needs flexible conversation logic.

_Note: This project is currently under development._

## Import

1. **Download the Latest Release**

   - Download the latest release ZIP file from the [Releases page](https://github.com/GenelleGeerman/DialogueViewer/releases).

2. **Import into Godot**

   - In your Godot project, go to the **Asset Lib** (top middle) and select **Import...**
   - Choose the ZIP file you downloaded.
   - Select **Change Install Folder**.
   - Create an `addons` folder (if it doesn't exist) and select this folder.
   - Press **Install**.

3. **Enable the Plugin**
   - Go to **Project > Project Settings > Plugins**.
   - Enable DialogueViewer.
   - You should now see a button next to the Asset Lib button in Godot.

## Usage

### Dialogue Viewer

- After enabling the plugin, use the menu interface to create and visualize dialogues for your project.
- No programming is required for this part
- Simply use the DialogueViewer panel to manage your dialogue structure.
- The only requirement is that each Dialogue MUST have a Start Node and an End Node.
- For a visual reference, here’s a screenshot of the plugin in action:  
  ![Screenshot](https://github.com/user-attachments/assets/869fc301-f446-4333-9dd7-a70ddb38595d)

### Dialogue Reader

- To use the Dialogue in Game, all you need is a node with the dialogue_reader script attached
- Assign the Dialogue Resource you made to the Dialogue Field.
- The dialogue_reader has a signal you can listen to called end_reached. This will get called when you have reached the end of the dialogue
- To start reading, call the get_next_line() function from the dialogue_reader. This returns a Dialogue Object
  Check below for an example
  
![Demo](https://github.com/user-attachments/assets/44da79c8-f897-4c7e-bc3d-5dc26b61f632)
  
![image](https://github.com/user-attachments/assets/4e6023b0-c66b-41da-a75f-ee8e96f1e852)

![image](https://github.com/user-attachments/assets/05026fbb-b5ea-4310-b972-ffdd0589a733)

![image](https://github.com/user-attachments/assets/4430fb8e-2be0-4c46-b817-cb726cd39dd6)


