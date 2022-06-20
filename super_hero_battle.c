
/****
  
  Programming Concepts - Assignment Two, sp2 2022
  
  Provided File:  Please add your solution to this file (code and comments).
  
  : )

    File : assign2_wayby001.c
	Author : Batman
	Stud ID : 0123456X
	Email ID : wayby001
	This is my own work as defined by the
	University's Academic Misconduct Policy.

****/


#define _CRT_SECURE_NO_WARNINGS /* Avoid some unimportant waring */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>


#define STRING_LENGTH  21   /* Maximum length of strings (20 characters plus one for the null character) */
#define MAX_CHARACTERS 10   /* Maximum characters stored in array of characters */


/* Function Prototype */
int read_character_file(FILE*, char character_array[][STRING_LENGTH], int health_array[]); 
void display_characters(char character_array[][STRING_LENGTH], int health_array[]);
int find_character(char character_array[][STRING_LENGTH], int health_array[],int no_characters, char target[STRING_LENGTH]);
void dispaly_highest_health(char character_array[][STRING_LENGTH], int health_array[], int no_characters);
void do_battle(char character_array[][STRING_LENGTH], int health_array[], int no_characters);
int add_character(char character_array[][STRING_LENGTH], int health_array[], int no_characters);
//int remove_character(char character_array[][STRING_LENGTH], int health_array[], int no_characters);
//void write_to_file(char character_array[][STRING_LENGTH], int health_array[], int no_characters)

int main() {

	char character_array[MAX_CHARACTERS][STRING_LENGTH] = {'\0'};
	int health_array[MAX_CHARACTERS] = {0};

	char character_array_reset[MAX_CHARACTERS][STRING_LENGTH] = {'\0'};
	int health_array_reset[MAX_CHARACTERS] = {0};
	int no_characters_reset = 0;
	int reset_id; // id of full health of character
	int ori_id; // id of current health of character

	int no_characters = 0; // Total number of characters
	int i = 0;
	char option[STRING_LENGTH];
	int end = 1;
	int find_chara_pos;
	int add_ret;
	char target[STRING_LENGTH];
	char reset_charac[STRING_LENGTH];


	FILE* inFile;

	srand(time(NULL));

	inFile = fopen("characters.txt", "r");
	if (inFile == NULL) {
		printf("File not opened... Exiting Program.\n");
		exit(EXIT_FAILURE);
	}

	// Call function read_character_file to read from file and store character information 
	// character_array and health_array.
	no_characters = read_character_file(inFile, character_array, health_array);


	// Display information to the screen to ensure read_character_file() funciton is working correctly.
	// This is for development purposes only and will be removed... eventually  : )

	//printf("%s\n", "Initial information of characters:");
	//for (i = 0; i < no_characters; i++) {
	//	printf("%s\n%d\n", character_array[i], health_array[i]);
	//}

	while(end){

		// print prompt information
		printf("%s", "Please enter choice");
		printf("\n");
		printf("%s", "[list, search, reset, add, remove, high, battle, quit]:");									
		gets(option);

		// swithc the option
		if(strcmp(option,"list")==0){
			display_characters(character_array, health_array, no_characters);

		}else if(strcmp(option,"search")==0){
			printf("Please enter character's name:");
			gets(target);

			find_chara_pos = find_character(character_array, health_array, no_characters, target);
			if (find_chara_pos == -1)
			{
				printf("%s character is not found in character list.\n", target);
			}

			if (find_chara_pos >= 0)
			{
				printf("%s current health: %d%%\n",character_array[find_chara_pos], health_array[find_chara_pos]);
			}

		}else if(strcmp(option,"reset")==0){
			FILE* inFile;
			srand(time(NULL));
			inFile = fopen("characters.txt", "r");

			printf("Please input the character you want to reset health\n");
			scanf("%s", reset_charac);
			no_characters_reset = read_character_file(inFile, character_array_reset, health_array_reset);
			reset_id = find_character(character_array_reset, health_array_reset, no_characters_reset, reset_charac);
			ori_id = find_character(character_array, health_array, no_characters, reset_charac);
			health_array[ori_id] = health_array_reset[reset_id];
			printf("%s health has been reset!\n", reset_charac);
			fflush(stdin);

		}else if(strcmp(option,"add")==0){
			//add_character(character_array, health_array, no_characters);
			add_ret = add_character(character_array, health_array, no_characters);
			if (add_ret == 1)
				no_characters++;


		}else if(strcmp(option,"remove")==0){
			printf("Input the name");

		}else if(strcmp(option,"high")==0){
			dispaly_highest_health(character_array, health_array, no_characters);

		}else if(strcmp(option,"battle")==0){
			do_battle(character_array, health_array, no_characters);

		}else if(strcmp(option,"quit")==0){
			printf("NOTE: Your program should output the following information to a file - new_characters.txt.\n");
			//write_to_file(character_array, health_array, no_characters);
			end = 0;

		}else{
			printf("%s\n", "Not a valid command - Please try again");
		}

	}

	return 0;
}

int add_character(char character_array[][STRING_LENGTH], int health_array[], int no_characters){

	int i, ret, new_health;
	char new_name[STRING_LENGTH];
	char add_character_array[MAX_CHARACTERS][STRING_LENGTH] = {'\0'};

	// Judge the character full
	//printf("%d%d",no_characters,sizeof(health_array));

	if (no_characters >= MAX_CHARACTERS){
		printf("The charater list is full! Can not add a new character!\n:");
		fflush(stdin);
		return -1;
		
	}
	
	printf("Please enter new character's name:");
	scanf ("%s",character_array[no_characters-1]);
	//scanf("%s", new_name);

	// Judge the character is in the array
	ret = find_character(character_array, health_array, no_characters, new_name);
	if (ret >= 0)
	{
		printf("The input charater is in the list!\n:");
		fflush(stdin);
		return 0;
	}
		
	printf("Please enter new character's health:");
	scanf("%d", &new_health);
	
	//character_array = new_name;
	health_array[no_characters] = new_health;
	//printf("%s", character_array[no_characters-1]);
	

	fflush(stdin);
	return 1;

}

/***
int remove_character(char character_array[][STRING_LENGTH], int health_array[], int no_characters){

	int ret;
	char new_name[STRING_LENGTH];

	// Judge the character array is empty
	// printf("%d%d",no_characters,sizeof(health_array));
	if (no_characters == 0){
		return -1;
	}
	
	// Judge the character is in the array
	ret = find_character(character_array, health_array, no_characters);
	if (ret == -1)
		return 0;
	
	printf("Please enter removed character's name:");
	ets(character_array[no_characters]);

	return 1;

}
***/

/****
void write_to_file(char character_array[][STRING_LENGTH], int health_array[], int no_characters){
	FILE * fp = NULL;
	int i;
	fp=fopen("new_characters.txt","w");

	for (i = 0; i < no_characters; i++) {
		fprintf(fp, "%d\n", health_array[i]);
		}
	fclose(fp);
}
****/

void do_battle(char character_array[][STRING_LENGTH], int health_array[], int no_characters){
	int cur_round=0, posa=-1, posb=-1, round;
	char namea[STRING_LENGTH], nameb[STRING_LENGTH];
	char ch1;

	printf("Please enter number of battle rounds(Must between 1-5):");
	scanf("%d", &round);

	printf("Please enter opponent one's name:");
	while (posa < 0 )
	{
		
		scanf("%s", namea);

		posa = find_character(character_array, health_array, no_characters, namea);
		if (posa < 0)
			printf("The %s not found in the character list, plaese enter another opponent!",namea);
	}

	
	printf("Please enter opponent two's name:");
	while (posb < 0 )
	{
		scanf("%s", nameb);
		posb = find_character(character_array, health_array, no_characters, nameb);
		if (posb < 0)
			printf("The %s not found in the character list, plaese enter another opponent!", nameb);
	}


	while (cur_round<round  && health_array[posa] > 0 && health_array[posb] > 0){

		health_array[posa] -= rand()%6;
		health_array[posb] -= rand()%6;
		cur_round += 1;
		printf("After round %d, The %s health is %d\n",cur_round,character_array[posa],health_array[posa]);
		printf("After round %d, The %s health is %d\n",cur_round,character_array[posb],health_array[posb]);
	}

    // Judge the winner
	printf("---------------------------------\n");
	if (health_array[posa] > health_array[posb])
		printf("***The winner is %s!***\n",character_array[posa]);
	else
		printf("***The winner is %s!***\n",character_array[posb]);
	printf("---------------------------------\n");

	fflush(stdin);

	// Judge the death
	if (health_array[posa] <= 0){
		printf("%s is dead",character_array[posa]);
	}
	if (health_array[posb] <= 0){
		printf("%s is dead\n",character_array[posb]);


	}
	
}


void dispaly_highest_health(char character_array[][STRING_LENGTH], int health_array[], int no_characters){

	int high_ind = 0;
	int biggest = 0;
	int i;

	for (i = 0; i < no_characters; i++) {
		if (health_array[i] > biggest){
			biggest = health_array[i];
		}
	}
	printf("Characters with the highest health rating of %d%% are:\n", biggest);

	for (i = 0; i < no_characters; i++) {
		if (health_array[i] == biggest){
			printf("--> %s\n", character_array[i]);
		}
	}
}


int find_character(char character_array[][STRING_LENGTH], int health_array[],int no_characters, char target[STRING_LENGTH]){
	int i;
	int judge = 1;

	for (i = 0; i < no_characters; i++) {
		if (strcmp(target,character_array[i])==0){
			judge = 0;
			return i;
		}
			
	}
	
	if (judge){
		return -1;
	
	}
}


int read_character_file(FILE* infile, char character_array[][STRING_LENGTH], int health_array[]) {

	char name[STRING_LENGTH];
	int  i = 0;

	fgets(name, STRING_LENGTH, infile);

	while (i < MAX_CHARACTERS && !feof(infile))
	{
		name[strlen(name) - 1] = '\0';
		strcpy(character_array[i], name);

		fscanf(infile, "%d ", &health_array[i]);

		i++;

		fgets(name, STRING_LENGTH, infile);
	}

	return i;
}


void display_characters(char character_array[][STRING_LENGTH], int health_array[], int no_characters){

	int i = 0;
	printf("=======================================\n");
	printf("-          Character Summary          -\n");
	printf("=======================================\n");
	printf("-  Name                       Health  -\n");
	printf("=======================================\n");

	for (i = 0; i < no_characters; i++) {
		printf("-  %-14s%19d  -\n", character_array[i], health_array[i]);
		printf("---------------------------------------\n");
	}
	printf("=======================================\n");
}


