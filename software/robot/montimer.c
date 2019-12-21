#define INTERVAL_TIMER_BASE 0x90002000
// description de fonctions pour la gestion du temps
unsigned int Timer_period;

int getperiod() {
	int val= *(((volatile unsigned int*)INTERVAL_TIMER_BASE)+2)|
			(*(((volatile unsigned int*)INTERVAL_TIMER_BASE)+3)<<16);
	Timer_period=val;
	return val;
}

void start_timer() {
	*(((volatile unsigned int*)INTERVAL_TIMER_BASE)+1)=0x06;
}

unsigned int getsnap() {
	*(((volatile unsigned int*)INTERVAL_TIMER_BASE)+4)=0;
	unsigned int val= *((volatile unsigned int*)(INTERVAL_TIMER_BASE)+4)|
			(*(((volatile unsigned int*)INTERVAL_TIMER_BASE)+5)<<16);
	return val;
}
unsigned int getsnapdif(unsigned int v1,unsigned int v2){
  return ((v1>=v2) ? (v1-v2) :(Timer_period-v2+v1));
}

