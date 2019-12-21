
#include <stdio.h>
#include <stdlib.h>
#include "montimer.h"

// constante des l'adresses des periphériques

// completer les bonnes valeurs
#define OMOTEUR  *((volatile unsigned int *) 0x82000020)
//#define captX654  *((volatile unsigned int *) 0x82000010)
//#define capt3210  *((volatile unsigned int *) 0x82000020)
//#define det  	*((volatile unsigned char *) 0x82000013)

/*********************************************************/
/*********************************************************/
//   Fonctions  

#define OCAPT3   *((volatile unsigned int *) 0x82000010)
#define OCAPT6   *((volatile unsigned int *) 0x82000030)
#define calcule *((volatile char *) 0x82000033)



int main(){
// initialiser Timer de mesure du temps
  getperiod();
  start_timer();
/*******************/
// Boucle principale
    unsigned int Vmoy = 0x2850;
    unsigned int Vmin = 0x2780;
  	//unsigned char PDU, PPU,masque;
  	signed char position;
  	//unsigned int n, v1, v2, t1, t2,t3,t4;
  	unsigned int t1, t2,t3,t4,v1,v2;
   unsigned int nbun;
   int erreur;
  	unsigned int K =4*(Vmoy-Vmin)/6;
  	int erreur2;
  	t1 = getsnap();

  	int etat_sup = 0;
  	int etat_rot = 0;
  	int start_rot = 0;
  	int fin_rot =0 ;
  	//OMOTEUR = 0x29992999;
	printf("pre-while\n");
  	while(1){
  		printf("etat_sup=%d  etat_rot=%d",etat_sup,etat_rot);
  		//OMOTEUR=0x29402940;
  		nbun=(int)((calcule & 0xF0)>>4);
  		erreur = (int)(calcule & 0x0F);
		if((erreur & 0x08) == 0x08){
				erreur = (0x0F ^ erreur)+1;
				erreur *= -1;
		}
		if(start_rot == 0){
  		switch(etat_sup){
  			case 0: //etat d'arret
  				v2=0x0000;v1=0x0000;
  				if(nbun!=0)
  					etat_sup = 1;
  				else
  					etat_sup=0;

  				break;
  			case 1: //etat suivi de ligne
  				if(nbun==0)
  					etat_sup=2;
  				t2 = getsnap();
  				t1 = getsnap();
  				if(getsnapdif(t2,t1)>10000)
  				{
					t1 = getsnap();
					  if(nbun!=0)
					  {
						  v2 = Vmoy + erreur*K;
						  v1 = Vmoy - erreur*K;
					  }
					  else
					  {
						  v2=0x0000;
						  v1=0x0000;
					  }
					OMOTEUR = ((v1<<16) + v2);
					t1 = getsnap();

  				}
  				break;
  			case 2: //etat rotation
  				v2=0x0000;v1=0x0000;
  				etat_rot =1;
  				start_rot=1;
  				break;

  		}
		}
		else{
  		switch(etat_rot){
  			case 0: //etat d'arret
  				fin_rot = 0;
  				etat_rot=1;
  				break;
  			case 1: //rotation rapide
  				t3 = getsnap();
				if(getsnapdif(t3,t4)>10000)
				{
					t4 = getsnap();
					v2=0x2940;
					v1=0x0000;
					if(nbun!=0){
						v1 = 0x0000;
						v2 = v1;
						etat_rot=3;
					}
				}
				else
					v1=0x2940;
  				break;
  			case 2: //rotation lente
  				break;
  			case 3: //fin de rotation
  				fin_rot = 1;
  				start_rot=0;
  				break;


  		}
  		//detection = (OCAPT6>>3);
  		}

  	}
}





/*
int main(){
// initialiser Timer de mesure du temps
  getperiod();
  start_timer();
  int t1,t2,t3;
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

*/



