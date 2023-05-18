;                        ****************************************************************************************
;                        ****************************************************************************************
;                        **                                                                                    ** 
;                        **   ==============================================================================   **
;                        **   =---------------- Computer Organization & Assembly Language -----------------=   **
;                        **   ==============================================================================   **
;                        **   =------------------------ 4th Semester Project ------------------------------=   **
;                        **   =---------------------------- Spring 2023 -----------------------------------=   **
;                        **   ==============================================================================   **
;                        **   =----------------------- RENT MANAGEMENT SYSTEM -----------------------------=   **
;                        **   ==============================================================================   **
;                        **   =---------------------------- Group Members ---------------------------------=   **
;                        **   ==============================================================================   **
;                        **   =------------------------ Ebaa Haq (2021-CE-22) -----------------------------=   **
;                        **   =---------------------- Maham Nadeem (2021-CE-10) ---------------------------=   **
;                        **   =----------------------- Faiza Riaz (2021-CE-20) ----------------------------=   **
;                        **   =----------------------- Aliya Zahra (2021-CE-16) ---------------------------=   **
;                        **   ==============================================================================   **
;                        **                                                                                    **
;                        ****************************************************************************************
;                        ****************************************************************************************


INCLUDE Irvine32.inc

;BUFFER_SIZE = 501

.DATA

Welcome DB    ' ',0ah,'                                       ****Welcome to Rent & Grab****                                ',0ah
Menu DB       ' ',0ah, '1. Bike (Rs. 150 per Hour)', 0ah, '2. Car (Rs. 1000 per Hour)', 0ah, '3. Returning Bike ', 0ah, '4. Returning Car ', 0ah, '5. Exit', 0ah, 'Enter your choice: ', 0ah,0
VExit DB     ' ',0ah,'                                        Thanks for visiting us.                                       ',0ah,0 
invalid DB     ' ',0ah, 'Invalid choice! Please choose again.' , 0ah,0
NextLine BYTE ' ' , 0ah,0

;input variables
V_Name DB     ' ',0ah, 'Enter Vehicle Name: ',0ah,0
V_Model DB    'Enter Vehicle Model: ',0ah,0
V_Time DB     'Enter Time: ',0ah,0
vehicleName     BYTE    20 DUP(?)   ; vehicle  name string variable
vehicleModel    BYTE    20 DUP(?)   ; vehicle model string variable
vehicleTime     DWORD    ?           ; vehicle time variable


ReturnBike_Name DB     ' ',0ah, 'Enter Returning Bike Name: ',0ah,0
ReturnCar_Name DB     ' ',0ah, 'Enter Returning Car Name: ',0ah,0
BikeName     BYTE    20 DUP(?)   ; returning bike name string variable
CarName    BYTE    20 DUP(?)   ; returning Car name string variable
ReturnVehicleName    BYTE  '                    ' ,0     ; returning vehicle name string variable

; filehandling variables
NotAvailable DB     ' ',0ah, 'Vehicle is not available. ' , 0ah,0
Available DB ' ' ,0ah , 'Vehicle is available. ' , 0ah,0
ReadError    BYTE    "Error opening or reading file.",0
WriteError    BYTE    "Error opening or writng file.",0
filehandle  HANDLE  ?
charsread   DWORD   ?
totalFare DWORD ?

; Bike FILE HANDLING VARIABLES
Bikefile    BYTE    "BIKES.txt",0
Bikebuffer      BYTE    350 DUP (?)
bikeFarePerHour DWORD 150  ;(96) in  hex. (150) in decimal 
BikefareMsg BYTE "The total fare for renting the bike is Rs.", 0
bytesRead dword 1 dup(0)


; CAR FILE HANDLING VARIABLES
Carfile    BYTE    "CARS.txt",0
Carbuffer      BYTE    350 DUP (?)
CarFarePerHour DWORD 1000  ;(3E8) in  hex. (1000) in decimal 
CarfareMsg BYTE "The total fare for renting the Car is Rs.", 0


; CLIENT INFORMATION VARIABLES
C_Name DB     ' ',0ah, 'Enter Name: ',0ah,0
C_Number DB    'Enter Phone Number: ',0ah,0
C_Address DB     'Enter Address: ',0ah,0

ClientName BYTE 20 DUP(?)
ClientNumber BYTE 20 DUP(?)
ClientAddress BYTE 20 DUP(?)

; CLIENT INFORMATION FILE HANDLING VARIABLES
ClientFile    BYTE    "CLIENTS.txt",0
writeFileHandle DWORD ?
WriteDone BYTE "Data appended successfully.",0
bytesWritten BYTE ?



.CODE
MAIN PROC
 
     ; Print the Welcome
     mov edx, OFFSET Welcome
     call WriteString


     ; Read user's choice
     call ReadChar
     mov bl, al
     call writechar
    
     ; Check user's choice
     CMP BL, '1'
     JE BIKE
     CMP BL, '2'
     JE CAR
     CMP BL, '3'
     JE ReturningBike
     CMP BL, '4'
     JE ReturningCar
     CMP BL, '5'
     JE exit1

     ; Invalid choice
     mov edx, OFFSET invalid
     call WriteString

     ; Jump back to the menu
     JMP MAIN

BIKE:
     ; Code for BIKE SPECIFICATIONS goes here
     ; get input for bike name

     mov edx, OFFSET V_Name
     call WriteString
     mov edx, OFFSET vehicleName     ; load address of bike Name
     mov ecx, SIZEOF vehicleName     ; load size of bike Name
     call ReadString             ; read a string from keyboard
     mov byte ptr [vehicleName + eax], 0 ; add null terminator to end of string
    
     ; get input for bike model
     mov edx, OFFSET V_Model
     call WriteString
     mov edx, OFFSET vehicleModel    ; load address of bike Model
     mov ecx, SIZEOF vehicleModel    ; load size of bike Model
     call ReadString             ; read a string from keyboard
     mov byte ptr [vehicleModel + eax], 0 ; add null terminator to end of string
    
     ; get input for bike time
     mov edx, OFFSET V_Time
     call WriteString
     mov edx, OFFSET vehicleTime     ; load address of bikeTime
     call ReadInt                ; read an integer from keyboard
     mov vehicleTime, eax


     ; FILE HANDLING FOR BIKE
    INVOKE CreateFile,
		ADDR BikeFile,		; ptr to filename
		GENERIC_READ,			; mode = Can read
		DO_NOT_SHARE,			; share mode
		NULL,				; ptr to security attributes
		OPEN_ALWAYS,			; open an existing file
		FILE_ATTRIBUTE_NORMAL,	; normal file attribute
		0				; not used
	mov filehandle, eax			; Copy handle to variable


BikeReadLoop:
     mov ebx, LENGTHOF Bikebuffer
     mov edx, OFFSET Bikebuffer
     mov ecx, ebx
     mov eax, filehandle ; move the file handle into eax before calling ReadString
     call ReadFromFile
     mov charsread, eax ; save the number of characters read
     ; call dumpregs
     cmp charsread, 0 ; check if end of file has been reached
     je BikeFileEnd

     ;displaying file data that is being read
     mov byte ptr [Bikebuffer + eax], 0
     mov edx, OFFSET Bikebuffer
    
     call WriteString
     call Crlf

     ; entered vehicle is available in file
     mov esi, OFFSET Bikebuffer ; Load address of string into SI
     mov edi, OFFSET VehicleModel ; Load address of substring into DI

     mov ecx, 0 ; Set up counter to track length of substring
     cld ; Clear direction flag to move forward through string

BikeSearch_loop:
     lodsb ; Load byte from string into AL and increment SI
     cmp al, [edi+ecx] ; Compare byte to corresponding character in substring
     jne BikeReset_di ; If characters do not match, reset DI and continue searching
     inc ecx ; If characters match, increment counter
     cmp byte ptr [edi+ecx], 0 ; Check if end of substring has been reached
     jne BikeSearch_loop ; If not, continue searching

     ; If end of substring has been reached, the substring has been found
     mov eax, 1 ; Set EAX to 1 to indicate success
     jmp BikeFound ; Exit the program

BikeReset_di:
     mov ecx, 0 ; Reset counter to 0
     mov edi, OFFSET VehicleModel ; Reset DI to beginning of substring
     jmp BikeContinue_search ; Continue searching string

BikeContinue_search:
     cmp byte ptr [esi], 0 ; Check if end of string has been reached
     jne BikeSearch_loop ; If not, continue searching

     ; If end of string has been reached, the substring is not present
     mov edx, OFFSET NotAvailable
     call WriteString
     jmp MAIN


BikeFound:
     
     ; close the file
     invoke CloseHandle, filehandle
     call CloseFile

     mov edx, OFFSET Available
     call WriteString
     jmp BikeClient

BikeFileEnd:
     invoke CloseHandle, filehandle
     call CloseFile
     jmp main

BikeFileError:
     invoke CloseHandle, filehandle
     call CloseFile
     mov edx, OFFSET ReadError
     call WriteString
     call Crlf
     jmp main


BikeClient:
    
     ; Client Information
     ; get input of client name
     mov edx, OFFSET C_Name
     call WriteString
     mov edx, OFFSET ClientName     ; load address of client Name
     mov ecx, SIZEOF ClientName     ; load size of client Name
     call ReadString             ; read a string from keyboard
     mov byte ptr [ClientName + eax], 0 ; add null terminator to end of string
     
     ; get input of client phone number
     mov edx, OFFSET C_Number
     call WriteString
     mov edx, OFFSET ClientNumber    ; load address of Client Number
     mov ecx, SIZEOF ClientNumber    ; load size of Client Number
     call ReadString             ; read a string from keyboard
     mov byte ptr [ClientNumber + eax], 0 ; add null terminator to end of string
    
     ; get input for Client Address
     mov edx, OFFSET C_Address
     call WriteString
     mov edx, OFFSET ClientAddress    ; load address of Client Address
     mov ecx, SIZEOF ClientAddress    ; load size of Client Address
     call ReadString             ; read a string from keyboard
     mov byte ptr [ClientAddress + eax], 0 ; add null terminator to end of string

     mov edx, OFFSET NextLine
     call WriteString
     mov edx, OFFSET ClientName
     call WriteString
     mov edx, OFFSET NextLine
     call WriteString
     mov edx, OFFSET ClientNumber
     call WriteString
     mov edx, OFFSET NextLine
     call WriteString
     mov edx, OFFSET ClientAddress
     call WriteString
     mov edx, OFFSET NextLine
     call WriteString
     mov edx, OFFSET NextLine
     call WriteString


     ;FILE HANDLING of CLIENT INFORMATION
     ; Open the file in append mode
     invoke CreateFile, ADDR Clientfile, FILE_APPEND_DATA, FILE_SHARE_READ, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
     mov WriteFileHandle, eax ; Save the file handle

     ; Append the data to the file
     invoke WriteFile, WriteFileHandle, ADDR ClientName, LENGTHOF ClientName, ADDR bytesWritten, 0
     invoke WriteFile, WriteFileHandle, ADDR ClientNumber, LENGTHOF ClientName, ADDR bytesWritten, 0
     invoke WriteFile, WriteFileHandle, ADDR ClientAddress, LENGTHOF ClientName, ADDR bytesWritten, 0
     invoke WriteFile, WriteFileHandle, ADDR VehicleModel, LENGTHOF ClientName, ADDR bytesWritten, 0
    
     ; Close the file
     invoke CloseHandle, WriteFileHandle

      jmp BikeClientDoneWrite
BikeClientDoneWrite:
     ; Display success message
     mov edx, OFFSET WriteDone
     call WriteString

     jmp BikePayment

BikePayment:

     ; Calculate the total fare
     mov eax, 0
     mov eax, bikeFarePerHour
     mul VehicleTime
     mov totalFare, eax

     ; Display the total fare to the user
     mov edx, OFFSET NextLine
     call WriteString
     mov edx, OFFSET BikefareMsg
     call WriteString
     call WriteDec
     call Crlf
     jmp main

CAR:
     ; Code for CAR SPECIFICATIONS goes here
     ; get input for car name
     mov edx, OFFSET V_Name
     call WriteString
     mov edx, OFFSET vehicleName     ; load address of car Name
     mov ecx, SIZEOF vehicleName     ; load size of car Name
     call ReadString             ; read a string from keyboard
     mov byte ptr [vehicleName + eax], 0 ; add null terminator to end of string
    
     ; get input for car model
     mov edx, OFFSET V_Model
     call WriteString
     mov edx, OFFSET vehicleModel    ; load address of car Model
     mov ecx, SIZEOF vehicleModel    ; load size of car Model
     call ReadString             ; read a string from keyboard
     mov byte ptr [vehicleModel + eax], 0 ; add null terminator to end of string
    
     ; get input for car time
     mov edx, OFFSET V_Time
     call WriteString
     mov edx, OFFSET vehicleTime     ; load address of car Time
     call ReadInt                ; read an integer from keyboard
     mov vehicleTime, eax
    

     ; FILE HANDLING FOR CAR
     mov edx, OFFSET Carfile
     call OpenInputFile
     cmp eax, INVALID_HANDLE_VALUE ; check if the file handle is valid
     je BikeFileError
     mov filehandle, eax

CarReadLoop:
     mov ebx, LENGTHOF Carbuffer
     mov edx, OFFSET Carbuffer
     mov ecx, ebx
     mov eax, filehandle ; move the file handle into eax before calling ReadString
     call ReadFromFile
     mov charsread, eax ; save the number of characters read
     ;call dumpregs
     cmp charsread, 0 ; check if end of file has been reached
     je CarFileEnd

     ;displaying file data that is being read
     mov byte ptr [Carbuffer + eax], 0
     mov edx, OFFSET Carbuffer
    
     call WriteString
     call Crlf

     ; entered vehicle is availabe in file
     mov esi, OFFSET Carbuffer ; Load address of string into SI
     mov edi, OFFSET VehicleModel ; Load address of substring into DI

     mov ecx, 0 ; Set up counter to track length of substring
     cld ; Clear direction flag to move forward through string

CarSearch_loop:
     lodsb ; Load byte from string into AL and increment SI
     cmp al, [edi+ecx] ; Compare byte to corresponding character in substring
     jne CarReset_di ; If characters do not match, reset DI and continue searching
     inc ecx ; If characters match, increment counter
     cmp byte ptr [edi+ecx], 0 ; Check if end of substring has been reached
     jne CarSearch_loop ; If not, continue searching

     ; If end of substring has been reached, the substring has been found
     mov eax, 1 ; Set EAX to 1 to indicate success
     jmp CarFound ; Exit the program

CarReset_di:
     mov ecx, 0 ; Reset counter to 0
     mov edi, OFFSET VehicleModel ; Reset DI to beginning of substring
     jmp CarContinue_search ; Continue searching string

CarContinue_search:
     cmp byte ptr [esi], 0 ; Check if end of string has been reached
     jne CarSearch_loop ; If not, continue searching

     ; If end of string has been reached, the substring is not present
     mov edx, OFFSET NotAvailable
     call WriteString
     jmp MAIN


Carfound:

     ; close the file
     invoke CloseHandle, filehandle
     call CloseFile
     mov edx, OFFSET Available
     call WriteString

     jmp CarClient

CarFileEnd:
     invoke CloseHandle, filehandle
     call CloseFile
     jmp main

CarFileError:
     invoke CloseHandle, filehandle
     call CloseFile
     mov edx, OFFSET ReadError
     call WriteString
     call Crlf
     jmp main

CarClient:
    
     ; Client Information
     ; get input of client name
     mov edx, OFFSET C_Name
     call WriteString
     mov edx, OFFSET ClientName     ; load address of client Name
     mov ecx, SIZEOF ClientName     ; load size of client Name
     call ReadString             ; read a string from keyboard
     mov byte ptr [ClientName + eax], 0 ; add null terminator to end of string
     
     ; get input of client phone number
     mov edx, OFFSET C_Number
     call WriteString
     mov edx, OFFSET ClientNumber    ; load address of Client Number
     mov ecx, SIZEOF ClientNumber    ; load size of Client Number
     call ReadString             ; read a string from keyboard
     mov byte ptr [ClientNumber + eax], 0 ; add null terminator to end of string
    
     ; get input for Client Address
     mov edx, OFFSET C_Address
     call WriteString
     mov edx, OFFSET ClientAddress    ; load address of Client Address
     mov ecx, SIZEOF ClientAddress    ; load size of Client Address
     call ReadString             ; read a string from keyboard
     mov byte ptr [ClientAddress + eax], 0 ; add null terminator to end of string


     mov edx, OFFSET NextLine
     call WriteString
     mov edx, OFFSET ClientName
     call WriteString
     mov edx, OFFSET NextLine
     call WriteString
     mov edx, OFFSET ClientNumber
     call WriteString
     mov edx, OFFSET NextLine
     call WriteString
     mov edx, OFFSET ClientAddress
     call WriteString
     mov edx, OFFSET NextLine
     call WriteString


     
     ;FILE HANDLING of CLIENT INFORMATION
     ; Open the file in append mode
     invoke CreateFile, ADDR Clientfile, FILE_APPEND_DATA, FILE_SHARE_READ, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
     mov WriteFileHandle, eax ; Save the file handle


     ; Append the data to the file
     invoke WriteFile, WriteFileHandle, ADDR ClientName, LENGTHOF ClientName, ADDR bytesWritten, 0
     ; invoke WriteFile, WriteFileHandle, ADDR NextLine , LENGTHOF NextLine,ADDR byteswritten, 0
     invoke WriteFile, WriteFileHandle, ADDR ClientNumber, LENGTHOF ClientNumber, ADDR bytesWritten, 0
     ; invoke WriteFile, WriteFileHandle, ADDR NextLine , LENGTHOF NextLine,ADDR byteswritten, 0
     invoke WriteFile, WriteFileHandle, ADDR ClientAddress, LENGTHOF ClientAddress, ADDR bytesWritten, 0
     ; invoke WriteFile, WriteFileHandle, ADDR NextLine , LENGTHOF NextLine,ADDR byteswritten, 0
     invoke WriteFile, WriteFileHandle, ADDR VehicleModel, LENGTHOF VehicleModel, ADDR bytesWritten, 0
     ; invoke WriteFile, WriteFileHandle, ADDR NextLine , LENGTHOF NextLine,ADDR byteswritten, 0
    
     ; Close the file
     invoke CloseHandle, WriteFileHandle

      jmp CarClientDoneWrite
CarClientDoneWrite:
     ; Display success message
     mov edx, OFFSET WriteDone
     call WriteString

     jmp CarPayment


CarPayment:

     ; Calculate the total fare
     mov eax ,0
     mov eax, CarFarePerHour
     mul VehicleTime
     mov totalFare, eax

     ; Display the total fare to the user
     mov edx, OFFSET NextLine
     call WriteString
     mov edx, OFFSET CarfareMsg
     call WriteString
     call WriteDec
     call Crlf
     jmp main


ReturningBike:
     
     ; getting from user bike Name
     mov edx, OFFSET ReturnBike_Name
     call WriteString
     mov edx, OFFSET BikeName     ; load address of bike Name
     mov ecx, SIZEOF BikeName     ; load size of bike Name
     call ReadString             ; read a string from keyboard
     mov byte ptr [BikeName + eax], 0 ; add null terminator to end of string


     ; Open the file in append mode
     invoke CreateFile, ADDR BikeFile, FILE_APPEND_DATA, FILE_SHARE_READ, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
     mov WriteFileHandle, eax ; Save the file handle

     ; Append the data to the file
     invoke WriteFile, WriteFileHandle, ADDR BikeName, LENGTHOF BikeName, ADDR bytesWritten, 0
     

     ; Close the file
     invoke CloseHandle, WriteFileHandle

     jmp ReturnBikeDoneWrite
ReturnBikeDoneWrite:
     ; Display success message
     mov edx, OFFSET WriteDone
     call WriteString

     jmp main


ReturningCar:
     
     ; getting from user Car Name
     mov edx, OFFSET ReturnCar_Name
     call WriteString
     mov edx, OFFSET CarName     ; load address of Car Name
     mov ecx, SIZEOF CARName     ; load size of Car Name
     call ReadString             ; read a string from keyboard
     mov byte ptr [CarName + eax], 0 ; add null terminator to end of string


     ; Open the file in append mode
     invoke CreateFile, ADDR CarFile, FILE_APPEND_DATA, FILE_SHARE_READ, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
     mov WriteFileHandle, eax ; Save the file handle

     ; Append the data to the file
     invoke WriteFile, WriteFileHandle, ADDR CarName, LENGTHOF CarName, ADDR bytesWritten, 0
     

     ; Close the file
     invoke CloseHandle, WriteFileHandle

      jmp ReturnCarDoneWrite
ReturnCarDoneWrite:
     ; Display success message
     mov edx, OFFSET WriteDone
     call WriteString

     jmp main

exit1:
     mov edx, OFFSET VExit
     call WriteString
     exit 


MAIN ENDP
END MAIN
