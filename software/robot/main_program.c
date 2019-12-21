
#include <stdio.h>
#include <stdlib.h>
#include "montimer.h"

// constante des l'adresses des periphériques

// completer les bonnes valeurs
#define OMOTEUR  *((volatile unsigned int *) 0x82000000)
#define captX654  *((volatile unsigned int *) 0x82000010)
#define capt3210  *((volatile unsigned int *) 0x82000020)
#define det  	*((volatile unsigned char *) 0x82000013)

/*********************************************************/
/*********************************************************/
//   Fonctions  



int main(){
// initialiser Timer de mesure du temps
  getperiod();
  start_timer();
  int t1,t2,t3;
/*******************/
  //unsigned char det;
  unsigned char det2;
  t1 = getsnap();
  int posd,posp;
  int erreur=0;
  posd=0;
  posp=0;
  unsigned char motg, motd;
  while(1)
  {
	  t2 = getsnap();
	  if(getsnapdif(t1,t2)>1000000)
	  {
		  t1 = getsnap();

			int premier = 0;
			int dernier = 0;
			int i;
			int nbr = 0;
			for(i=0;i<7;i++)
			{
				det2=(det>>i);
				if(((det2) & (unsigned char)0x01 )==1)
				{
					premier=i;
					break;
				}
			}
			for(i=0;i<8;i++)
			{
				det2=(det<<i);
				if((det2) & (unsigned char)0x80)
				{
					dernier = 7-i;
					break;
				}

			}
			nbr=dernier-premier+1;
			  printf("premier= %d \t dernier= %d \n",premier,dernier);
			  OMOTEUR=0x29402940;
			  erreur = premier +dernier - 6;
			  printf("erreur %d \n",erreur);
			  if(erreur>=0)
				  motg = 0x2940+ (96*erreur);
			  else if(erreur<0)
				  motd = 0x2940- (96*erreur);
			  OMOTEUR = (motg<<16)+motd;
			  //char output[9];
			  //sprintf(output,"%x", OMOTEUR);
				//printf("OMOTEUR %u \n",OMOTEUR);
			  //printf("%s\n",output);
			  t3 = getsnap();
			  printf("t= %d \n",getsnapdif(t1,t3));
	  	  }

	}
  }





