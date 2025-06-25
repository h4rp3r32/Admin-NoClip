qb-adminnoclip
A QBCore-compatible noclip tool for administrators. This script allows authorized admins to freely move around the game world with noclip mode, toggle invisibility, and switch between first- and third-person perspectives, all while preserving immersion and stability.

✨ Features
✅ Admin-Only Access (permissions checked via server)

🚀 Fly Freely in any direction using WASD + QE

👻 Toggle Invisibility with N key (while in noclip)

🎥 Switch Camera Views between first/third person using Numpad 0

🔄 Smooth Controls with speed adjustment:

Shift: Fast speed

B: Slow speed

Default: Normal speed

🛑 Automatically disables collision, damage, and tasks while in noclip

📦 Lightweight and responsive, suitable for RP moderation tools

⛓ Dependencies
QBCore Framework

🚀 Installation
Place the script in your resources/[admin]/qb-adminnoclip folder.

Add to your server.cfg:

cfg
Copy
Edit
ensure qb-adminnoclip
Ensure the server-side counterpart is set up to handle:

qb-adminnoclip:checkPerms

qb-adminnoclip:setAdminStatus

🎮 Controls & Usage
Action	Key	Notes
Toggle Noclip	F6	Admin only
Toggle Invisibility	N	Only while in noclip
Toggle View Mode	V	Switches between 1st & 3rd person
Speed Up	Shift	While flying
Slow Down	B	While flying
Manual Toggle Command	/adminnoclip	Can be used as alternative

⚙ Server-Side Expectations
Your server should respond to the following events:

qb-adminnoclip:checkPerms
Triggered on client to ask the server if the player is an admin.

qb-adminnoclip:setAdminStatus
Should respond from server with:

lua
Copy
Edit
TriggerClientEvent("qb-adminnoclip:setAdminStatus", src, true/false)
You can use your existing admin rank system (e.g., group == "admin" in QBCore) to determine permissions.

🔧 Customization
Change Default Keys
Update these variables in the script:

lua
Copy
Edit
local noclipToggleKey = 167 -- F6
local invisToggleKey = 249  -- N
Find key codes: FiveM Control Keys

📌 Notes
The script uses TaskPlayAnim to add a floating idle animation (move_m@buzzed), which can be changed if needed.

On exit, the player is safely returned to the ground, with collision re-enabled.

While noclipped, normal game controls like jumping, crouching, and entering vehicles are disabled to prevent glitches.

👨‍💻 Credits
Developed for QBCore RP servers.

Built with administrator tools in mind for performance, support, and moderation.
