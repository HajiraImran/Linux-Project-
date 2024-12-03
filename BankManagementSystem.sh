#!/bin/bash

# Define colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
PINK="\033[1;35m"
RESET="\033[0m"

# Define a file to store account data
ACCOUNT_FILE="./accounts.txt"

ADMIN_PASSWORD="admin123"



create_account() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    CREATE NEW ACCOUNT"
    echo -e "=========================${RESET}"

    # Initialize or retrieve the last account number
    if [[ ! -f last_account_no.txt ]]; then
        echo "1000" > last_account_no.txt
    fi
    last_account_no=$(<last_account_no.txt)
    account_no=$((last_account_no + 1))
    echo "$account_no" > last_account_no.txt

    echo -e "${GREEN}Generated Account Number: $account_no${RESET}"

    read -p "Enter Account Holder Name: " holder_name
    if [ -z "$holder_name" ]; then
        echo -e "${RED}Account Holder Name cannot be empty!${RESET}"
        return
    fi

    read -p "Enter Type of Account (C/S): " account_type
    if [ -z "$account_type" ]; then
        echo -e "${RED}Account Type cannot be empty!${RESET}"
        return
    fi
    account_type=$(echo "$account_type" | tr '[:lower:]' '[:upper:]')

    if [[ "$account_type" != "C" && "$account_type" != "S" ]]; then
        echo -e "${RED}Invalid Account Type! Please enter 'C' for Current or 'S' for Saving.${RESET}"
        return
    fi

    read -p "Enter Initial Deposit Amount (>=440 for S, >=1000 for C): " deposit
    if [ -z "$deposit" ] || ! [[ "$deposit" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid deposit amount! Please enter a valid number.${RESET}"
        return
    fi

    # Validate minimum deposit requirements
    if [[ ($account_type == "S" && $deposit -lt 440) || ($account_type == "C" && $deposit -lt 1000) ]]; then
        echo -e "${RED}Insufficient initial deposit amount!${RESET}"
        return
    fi

    # If all checks pass, create the account
    echo "$account_no,$holder_name,$account_type,$deposit" >> "$ACCOUNT_FILE"
    echo -e "${GREEN}Account created successfully!${RESET}"

     # Display the updated account list
    echo -e "${CYAN}Updated Account List:${RESET}"
    cat "$ACCOUNT_FILE"


    read -p "Press Enter to return to the main menu..."
}



# Function to display account details
display_account() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    DISPLAY ACCOUNT"
    echo -e "=========================${RESET}"

    read -p "Enter Account Number: " account_no
    if grep -q "^$account_no," "$ACCOUNT_FILE"; then
        echo -e "${GREEN}Account Details:${RESET}"
        grep "^$account_no," "$ACCOUNT_FILE"
    else
        echo -e "${RED}Account number does not exist.${RESET}"
    fi
    read -p "Press Enter to return to the main menu..."
}

# Function to deposit money
deposit_money() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    DEPOSIT MONEY"
    echo -e "=========================${RESET}"

    read -p "Enter Account Number: " account_no
    read -p "Enter Amount to Deposit: " amount
    current_balance=$(grep "^$account_no," "$ACCOUNT_FILE" | cut -d ',' -f 4)

    if [[ -z $current_balance ]]; then
         
        echo -e "${RED}Account not found!${RESET}"
        read -p "Press Enter to return to the main menu..."
        return
        
    fi

    new_balance=$((current_balance + amount))
    sed -i -e "s/^$account_no,\(.*\),\(.*\),\(.*\)/$account_no,\1,\2,$new_balance/" "$ACCOUNT_FILE"
    echo -e "${GREEN}Amount deposited successfully!${RESET}"


    read -p "Press Enter to return to the main menu..."
}

# Function to withdraw money
withdraw_money() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    WITHDRAW MONEY"
    echo -e "=========================${RESET}"

    read -p "Enter Account Number: " account_no
    read -p "Enter Amount to Withdraw: " amount
    current_balance=$(grep "^$account_no," "$ACCOUNT_FILE" | cut -d ',' -f 4)

    if [[ -z $current_balance ]]; then
        echo -e "${RED}Account not found!${RESET}"
        return
    fi

    if (( current_balance < amount )); then
        echo -e "${RED}Insufficient balance!${RESET}"
        return
    fi

    new_balance=$((current_balance - amount))
    sed -i -e "s/^$account_no,\(.*\),\(.*\),\(.*\)/$account_no,\1,\2,$new_balance/" "$ACCOUNT_FILE"
    echo -e "${GREEN}Amount withdrawn successfully!${RESET}"
    read -p "Press Enter to return to the main menu..."
}

# Function to display all accounts
display_all_accounts() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    DISPLAY ALL ACCOUNTS"
    echo -e "=========================${RESET}"

    echo -e "${GREEN}Account Holder List:${RESET}"
    echo -e "Account No | Name | Type | Balance"
    echo -e "------------------------------------"
    column -t -s ',' "$ACCOUNT_FILE"
    read -p "Press Enter to return to the main menu..."
}

# Function to delete an account
delete_account() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    DELETE ACCOUNT"
    echo -e "=========================${RESET}"

    read -p "Enter Account Number to Delete: " account_no
    if grep -q "^$account_no," "$ACCOUNT_FILE"; then
        grep -v "^$account_no," "$ACCOUNT_FILE" > temp.txt && mv temp.txt "$ACCOUNT_FILE"
        echo -e "${GREEN}Account deleted successfully!${RESET}"
        
        # Display the updated account list
        echo -e "${CYAN}Updated Account List:${RESET}"
        cat "$ACCOUNT_FILE"
    else
        echo -e "${RED}Account number does not exist.${RESET}"
    fi
    read -p "Press Enter to return to the main menu..."
}



# Function to update account holder name
update_holder_name() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    UPDATE HOLDER NAME"
    echo -e "=========================${RESET}"

    read -p "Enter Account Number: " account_no
    if grep -q "^$account_no," "$ACCOUNT_FILE"; then
        read -p "Enter New Account Holder Name: " new_name
        sed -i -e "s/^$account_no,\(.*\),\(.*\),\(.*\)/$account_no,$new_name,\2,\3/" "$ACCOUNT_FILE"
        echo -e "${GREEN}Account holder name updated successfully!${RESET}"
        
        # Display the updated account list
        echo -e "${CYAN}Updated Account List:${RESET}"
        cat "$ACCOUNT_FILE"
    else
        echo -e "${RED}Account number does not exist.${RESET}"
    fi
    read -p "Press Enter to return to the main menu..."
}


# Function to search accounts by holder name
search_by_holder_name() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    SEARCH BY HOLDER NAME"
    echo -e "=========================${RESET}"

    read -p "Enter Account Holder Name to Search: " holder_name
    matches=$(grep ",$holder_name," "$ACCOUNT_FILE")
    if [[ -n $matches ]]; then
        echo -e "${GREEN}Matching Accounts:${RESET}"
        echo "$matches"
    else
        echo -e "${RED}No accounts found for the given name.${RESET}"
    fi
    read -p "Press Enter to return to the main menu..."
}

# Function to check minimum balance for accounts
check_minimum_balance() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    CHECK MINIMUM BALANCE"
    echo -e "=========================${RESET}"

    echo -e "${YELLOW}Accounts below minimum balance:${RESET}"
    while IFS=',' read -r account_no holder_name account_type balance; do
        if [[ $account_type == "S" && $balance -lt 440 || $account_type == "C" && $balance -lt 1000 ]]; then
            echo "$account_no | $holder_name | $account_type | $balance"
        fi
    done < "$ACCOUNT_FILE"
    read -p "Press Enter to return to the main menu..."
}

# Function to transfer money between accounts
transfer_money() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    TRANSFER MONEY"
    echo -e "=========================${RESET}"

    read -p "Enter Source Account Number: " source_account
    read -p "Enter Target Account Number: " target_account
    read -p "Enter Amount to Transfer: " amount

    source_balance=$(grep "^$source_account," "$ACCOUNT_FILE" | cut -d ',' -f 4)
    target_balance=$(grep "^$target_account," "$ACCOUNT_FILE" | cut -d ',' -f 4)

    if [[ -z $source_balance || -z $target_balance ]]; then
        echo -e "${RED}One or both accounts not found!${RESET}"
        return
    fi

    if (( source_balance < amount )); then
        echo -e "${RED}Insufficient balance in the source account!${RESET}"
        return
    fi

    new_source_balance=$((source_balance - amount))
    new_target_balance=$((target_balance + amount))

    sed -i -e "s/^$source_account,\(.*\),\(.*\),\(.*\)/$source_account,\1,\2,$new_source_balance/" "$ACCOUNT_FILE"
    sed -i -e "s/^$target_account,\(.*\),\(.*\),\(.*\)/$target_account,\1,\2,$new_target_balance/" "$ACCOUNT_FILE"

    echo -e "${GREEN}Transfer successful!${RESET}"
  

  
    read -p "Press Enter to return to the main menu..."
}
# Function to change the account type
change_account_type() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    CHANGE ACCOUNT TYPE"
    echo -e "=========================${RESET}"

    read -p "Enter Account Number: " account_no

    # Check if the account exists
    account_details=$(grep "^$account_no," "$ACCOUNT_FILE")
    if [[ -z $account_details ]]; then
        echo -e "${RED}Account number does not exist.${RESET}"
        read -p "Press Enter to return to the main menu..."
        return
    fi

    current_type=$(echo "$account_details" | cut -d ',' -f 3)

    read -p "Enter New Account Type (C/S): " new_account_type
    new_account_type=$(echo $new_account_type | tr '[:lower:]' '[:upper:]')

    # Check if the new type is valid
    if [[ $new_account_type != "C" && $new_account_type != "S" ]]; then
        echo -e "${RED}Invalid account type! Please enter 'C' for Current or 'S' for Savings.${RESET}"
        read -p "Press Enter to return to the main menu..."
        return
    fi

    # Check if the account type is already the same
    if [[ $current_type == $new_account_type ]]; then
        echo -e "${YELLOW}Account type is already '${current_type}'. No changes were made.${RESET}"
        read -p "Press Enter to return to the main menu..."
        return
    fi

    current_balance=$(echo "$account_details" | cut -d ',' -f 4)
# Validate balance for account type changes
if [[ "$new_account_type" == "C" && "$current_balance" -lt 1000 ]]; then
    echo -e "${RED}Balance does not meet the minimum requirement for the Current Account type (requires at least 1000).${RESET}"
    read -p "Press Enter to return to the main menu..."
    return
fi

if [[ "$new_account_type" == "S" && "$current_balance" -lt 440 ]]; then
    echo -e "${RED}Balance does not meet the minimum requirement for the Savings Account type (requires at least 440).${RESET}"
    read -p "Press Enter to return to the main menu..."
    return
fi



    # Update the account type in the file
    sed -i -e "s/^$account_no,\(.*\),$current_type,\(.*\)/$account_no,\1,$new_account_type,\2/" "$ACCOUNT_FILE"
    echo -e "${GREEN}Account type changed successfully to '${new_account_type}'!${RESET}"
    read -p "Press Enter to return to the main menu..."
}
# Function to generate a summary report
generate_report() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    BANK SUMMARY REPORT"
    echo -e "=========================${RESET}"

    if [[ ! -s $ACCOUNT_FILE ]]; then
        echo -e "${RED}No accounts found in the system!${RESET}"
        read -p "Press Enter to return to the main menu..."
        return
    fi

    # Initialize variables
    total_accounts=0
    total_balance=0
    savings_count=0
    current_count=0

    while IFS=',' read -r account_no holder_name account_type balance; do
        ((total_accounts++))
        ((total_balance += balance))
        if [[ $account_type == "S" ]]; then
            ((savings_count++))
        elif [[ $account_type == "C" ]]; then
            ((current_count++))
        fi
    done < "$ACCOUNT_FILE"

    # Calculate average balance
    if (( total_accounts > 0 )); then
        average_balance=$((total_balance / total_accounts))
    else
        average_balance=0
    fi

    # Display report
    echo -e "${GREEN}Total Accounts: ${RESET}$total_accounts"
    echo -e "${GREEN}Total Balance: ${RESET}₹$total_balance"
    echo -e "${GREEN}Average Balance per Account: ${RESET}₹$average_balance"
    echo -e "${GREEN}Savings Accounts: ${RESET}$savings_count"
    echo -e "${GREEN}Current Accounts: ${RESET}$current_count"

    read -p "Press Enter to return to the main menu..."
}


admin_login() {
    clear
    echo -e "${CYAN}========================="
    echo -e "       ADMIN LOGIN"
    echo -e "=========================${RESET}"

    read -sp "Enter Admin Password: " entered_password
    echo

    if [[ $entered_password == $ADMIN_PASSWORD ]]; then
        echo -e "${GREEN}Login successful!${RESET}"
        read -p "Press Enter to continue..."
        admin_menu
    else
        echo -e "${RED}Incorrect password. Returning to the main menu.${RESET}"
        read -p "Press Enter to continue..."
    fi
}

# Admin Menu
admin_menu() {
    while true; do
        clear
        echo -e "${CYAN}============================="
        echo -e "       ADMIN MODULE"
        echo -e "=============================${RESET}"
        echo -e "1. Create New Account"
        echo -e "2. Display Account"
        echo -e "3. Deposit Money"
        echo -e "4. Withdraw Money"
        echo -e "5. Display All Accounts"
        echo -e "6. Delete Account"
        echo -e "7. Update Holder Name"
        echo -e "8. Search by Holder Name"
        echo -e "9. Check Minimum Balance"
        echo -e "10. Transfer Money"
        echo -e "11. Change Account Type"
        echo -e "12. Generate Report"
        echo -e "13. Logout"
        echo -e "${CYAN}Enter your choice: ${RESET}"
        read choice

        case $choice in
            1) create_account ;;
            2) display_account ;;
            3) deposit_money ;;
            4) withdraw_money ;;
            5) display_all_accounts ;;
            6) delete_account ;;
            7) update_holder_name ;;
            8) search_by_holder_name ;;
            9) check_minimum_balance ;;
            10) transfer_money ;;
            11) change_account_type ;;
            12) generate_report ;;
            13) break ;;
            *) echo -e "${RED}Invalid option. Please try again.${RESET}" ;;
        esac
    done
}
# Function to log in as User
user_login() {
    clear
    echo -e "${CYAN}========================="
    echo -e "       USER LOGIN"
    echo -e "=========================${RESET}"

    read -p "Enter Account Number: " account_no

    if grep -q "^$account_no," "$ACCOUNT_FILE"; then
        echo -e "${GREEN}Login successful!${RESET}"
        read -p "Press Enter to continue..."
        user_menu "$account_no"
    else
        echo -e "${RED}Account number not found. Returning to the main menu.${RESET}"
        read -p "Press Enter to continue..."
    fi
}

# User Menu
user_menu() {
    local account_no=$1

    while true; do
        clear
        echo -e "${CYAN}============================="
        echo -e "       USER MODULE"
        echo -e "=============================${RESET}"
        echo -e "1. Display Account"
        echo -e "2. Deposit Money"
        echo -e "3. Withdraw Money"
        echo -e "4. Transfer Money"
        echo -e "5. Logout"
        echo -e "${CYAN}Enter your choice: ${RESET}"
        read choice

        case $choice in
            1) display_account ;;

            2)
                echo -e "${YELLOW}You are authorized to deposit money only to your account.${RESET}"
                sleep 2
                deposit_money "$account_no" ;;

            3)
                echo -e "${YELLOW}You are authorized to withdraw money only from your account.${RESET}"
                sleep 2
                withdraw_money "$account_no" ;;

            4)
                echo -e "${YELLOW}You can transfer money only from your account.${RESET}"
                sleep 2
                transfer_money "$account_no" ;;

            5) break ;;

            *) echo -e "${RED}Invalid option. Please try again.${RESET}" ;;
        esac
    done
}

deposit_money() {
    local account_no=${1:-""}

    clear
    echo -e "${CYAN}========================="
    echo -e "    DEPOSIT MONEY"
    echo -e "=========================${RESET}"

    if [[ -z $account_no ]]; then
        read -p "Enter Account Number: " account_no
    fi

    # Check if the account exists in the accounts file
    account_data=$(grep "^$account_no," "$ACCOUNT_FILE")

    if [[ -z $account_data ]]; then
        echo -e "${RED}Account not found!${RESET}"
        return
    fi

    # Extract the current balance
    current_balance=$(echo "$account_data" | cut -d ',' -f 4)

    read -p "Enter Amount to Deposit: " amount

    if [[ ! "$amount" =~ ^[0-9]+$ ]] || [[ "$amount" -le 0 ]]; then
        echo -e "${RED}Invalid amount. Please enter a positive number.${RESET}"
        return
    fi

    new_balance=$((current_balance + amount))

    # Update the account with the new balance
    sed -i -e "s/^$account_no,\(.*\),\(.*\),\(.*\)/$account_no,\1,\2,$new_balance/" "$ACCOUNT_FILE"

    echo -e "${GREEN}Amount deposited successfully! New balance: $new_balance${RESET}"
    read -p "Press Enter to return to the menu..."
}


withdraw_money() {
    local account_no=${1:-""}

    clear
    echo -e "${CYAN}========================="
    echo -e "    WITHDRAW MONEY"
    echo -e "=========================${RESET}"

    if [[ -z $account_no ]]; then
        read -p "Enter Account Number: " account_no
    fi

    # Check if the account exists
    account_data=$(grep "^$account_no," "$ACCOUNT_FILE")

    if [[ -z $account_data ]]; then
        echo -e "${RED}Account not found!${RESET}"
        return
    fi

    # Extract current balance
    current_balance=$(echo "$account_data" | cut -d ',' -f 4)

    read -p "Enter Amount to Withdraw: " amount

    # Validate if the amount is a positive number
    if [[ ! "$amount" =~ ^[0-9]+$ ]] || [[ "$amount" -le 0 ]]; then
        echo -e "${RED}Invalid amount. Please enter a positive number.${RESET}"
        return
    fi

    # Check if there are sufficient funds
    if (( current_balance < amount )); then
        echo -e "${RED}Insufficient balance!${RESET}"
        return
    fi

    new_balance=$((current_balance - amount))

    # Update the account balance in the file using sed
    sed -i -e "s/^$account_no,\(.*\),\(.*\),\(.*\)/$account_no,\1,\2,$new_balance/" "$ACCOUNT_FILE"

    echo -e "${GREEN}Amount withdrawn successfully! New balance: $new_balance${RESET}"
    read -p "Press Enter to return to the menu..."
}


# Modified Transfer Money Function for User Access
transfer_money() {
    local source_account=${1:-""}

    clear
    echo -e "${CYAN}========================="
    echo -e "    TRANSFER MONEY"
    echo -e "=========================${RESET}"

    if [[ -z $source_account ]]; then
        read -p "Enter Your Account Number: " source_account
    fi

    read -p "Enter Target Account Number: " target_account
    read -p "Enter Amount to Transfer: " amount

    source_balance=$(grep "^$source_account," "$ACCOUNT_FILE" | cut -d ',' -f 4)
    target_balance=$(grep "^$target_account," "$ACCOUNT_FILE" | cut -d ',' -f 4)

    if [[ -z $source_balance || -z $target_balance ]]; then
        echo -e "${RED}One or both accounts not found!${RESET}"
        return
    fi

    if (( source_balance < amount )); then
        echo -e "${RED}Insufficient balance in the source account!${RESET}"
        return
    fi

    new_source_balance=$((source_balance - amount))
    new_target_balance=$((target_balance + amount))

    sed -i -e "s/^$source_account,\(.*\),\(.*\),\(.*\)/$source_account,\1,\2,$new_source_balance/" "$ACCOUNT_FILE"
    sed -i -e "s/^$target_account,\(.*\),\(.*\),\(.*\)/$target_account,\1,\2,$new_target_balance/" "$ACCOUNT_FILE"

    echo -e "${GREEN}Transfer successful!${RESET}"
    read -p "Press Enter to return to the menu..."
}
if [[ ! -f "$ACCOUNT_FILE" ]]; then
    touch "$ACCOUNT_FILE"
fi
backup_accounts() {
    clear
    echo -e "${CYAN}========================="
    echo -e "    BACKUP ACCOUNTS"
    echo -e "=========================${RESET}"

    cp "$ACCOUNT_FILE" "$ACCOUNT_FILE.bak"
    echo -e "${GREEN}Backup created successfully!${RESET}"
    read -p "Press Enter to return to the main menu..."
}

main_menu() {
    
    while true; do
    
        clear
        echo -e "${CYAN}============================="
        echo -e "       MAIN MENU"
        echo -e "=============================${RESET}"
        echo -e "1. Admin Login"
        echo -e "2. User Login"
        echo -e "3. Exit"
        echo -e "${CYAN}Enter your choice: ${RESET}"
        read choice

        case $choice in
            1) admin_login ;;
            2) user_login ;;
            3) exit ;;
            *) echo -e "${RED}Invalid option. Please try again.${RESET}" ;;
        esac
    done
}

main_menu
