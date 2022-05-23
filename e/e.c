#include <18F4550.h>
#device ADC=10
#fuses HSPLL, NOWDT, NOPROTECT, NODEBUG, USBDIV, PLL5, CPUDIV1, VREGEN
#use delay(clock=48000000)
#byte porta = 0xf80 // Identificador para el puerto A. 
#byte portb = 0xf81 // Identificador para el puerto B. 
#byte portc = 0xf82 // Identificador para el puerto C. 
#byte portd = 0xf83 // Identificador para el puerto D. 
#byte porte = 0xf84 // Identificador para el puerto E.
//#define  USB_CONFIG_PID       0x000A
//#define  USB_CONFIG_VID       0x04D8
// if USB_CDC_ISR is defined, then this function will be called
// by the USB ISR when there incoming CDC (virtual com port) data.
// this is useful if you want to port old RS232 code that was use
// #int_rda to CDC.
#define USB_CDC_ISR() RDA_isr()
// in order for handle_incoming_usb() to be able to transmit the entire
// USB message in one pass, we need to increase the CDC buffer size from
// the normal size and use the USB_CDC_DELAYED_FLUSH option.
// failure to do this would cause some loss of data.
#define USB_CDC_DELAYED_FLUSH
#define USB_CDC_DATA_LOCAL_SIZE  128
static void RDA_isr(void);
// Includes all USB code and interrupts, as well as the CDC API
#include <usb_cdc.h>
#include <stdlib.h>
#include <string.h>
#define USB_CON_SENSE_PIN PIN_B2 //No usado cuando alimentado desde el USB
#define ENG1 PIN_B4
#define ENG2 PIN_B5
#define ENG3 PIN_B6
#define ENG4 PIN_B7
//Define la interrupción por recepción Serial
static void RDA_isr(void)
{  
   while(usb_cdc_kbhit())
   {
   /*char on;
    on = usb_cdc_getc();
    if(on == '1'){
      output_high(ENG1);
    } else {
      output_low(ENG1);
    }*/
    char dat[4];
    for(int i=0;i<=3;i++){
        dat[i]=usb_cdc_getc();
    }
    
    if(dat[0] == '1'){
      output_high(ENG1);
    } else {
      output_low(ENG1);
    }
    
    if(dat[1] == '1'){
      output_high(ENG2);
    } else {
      output_low(ENG2);
    }
    
    if(dat[2] == '1'){
      output_high(ENG3);
    } else {
      output_low(ENG3);
    }
    
    if(dat[3] == '1'){
      output_high(ENG4);
    } else {
      output_low(ENG4);
    }
  }
}
void main(){   
   int16 v=0;
   float p;
   char msg[32]; 
   
   setup_adc_ports(AN0);
   setup_adc(ADC_CLOCK_INTERNAL);
   set_adc_channel(0);
   
   set_tris_b(0b00000100);
   bit_clear(portb,4);
   bit_clear(portb,5);
   usb_cdc_init();
   usb_init();
   
   //enable_interrupts(INT_RDA); //Habilita Interrupción por serial (Recepcion USB_CDC)
   //enable_interrupts(GLOBAL);  //Habilita todas las interrupciones
   
   while(true){
      usb_task();  //Verifica la comunicación USB
      if(usb_enumerated()) {
         v = read_adc();
         p=(v / 1023.0)*500;
         sprintf(msg,"I%1.2fF",p); 
         printf(usb_cdc_putc,"%s",msg); 
         delay_ms(1000);
      }
   }
}
