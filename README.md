# Du-Simple-Access-Control

A script to control access with doors of force fields.

- It can control several doors and force fields at the same time.
- You can manage access with user name, user id, organisation name or organisation id.

## How to install

1. copy the script on the board
2. link the doors you want to control to the board
3. link the force fields you want to control to the board
4. link the screens where you want to diplay the access is granted or not to the board
5. link the zone detection to the board (with a relay if you want to use several). The link must be done from the detector to the board (blue link, not green).

## Mounting Scheme

![Mounting Scheme]()

## How to configure

In the Lua Parameters of the board (right click on the board > advanced > Lua parameters), you can change the following parameters:
- AllowedUsersId: the list of the users id allowed to access, comma separated.
- AllowedUsersName: the list of the users name allowed to access, comma separated, case sensitive.
- AllowedUserOrgsId: the list of the organisations id allowed to access, comma separated.
- AllowedUserOrgsName: the list of the organisations name allowed to access, comma separated, case sensitive.

![Lua Parameters]()