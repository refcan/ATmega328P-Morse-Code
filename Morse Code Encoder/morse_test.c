/**
 *  morse_test.c 02/12/12 (A.Gruning)J.Y.Clark, C. Cheong
 *  This lab material and corresponding solutions are 
 *  released under the Creative Commons Share-Alike 
 *  Non-Commercial Licence at 
 *  http://creativecommons.org/licenses/by-nc-sa/3.0/
 *  (C) Andre Gruning, 2011. Developed for COM1031 in 2011.
 *  (C) Jonathan Clark. 2012. Adapted for COM1031 in 2012.
 *  (C) Clive Cheong. 2013. Adapted for COM1031 in 2013.
 *	REFERENCES:
 *	[ATmega]: General 8-bit Atmel Microcontroller document 
 *  
 * 
 *  [ATmega328p]: Specific ATmega328p document (quite large!)
 *  downloadable from
 *  www.atmel.com/Images/doc7810.pdf
 *  [AVR]: Instruction Set Manual
 *  downloadable from
 *  www.atmel.com/Images/doc0856.pdf
 *
 * C-program that generates morse code with the timing a required for
 * the coursework.
 * 
 * The basic syntax of C is very similar to Java, so if you know Java
 * you can develop a passive understanding of a C program.
 *
 * This program send the characters in a string message repeatedly to
 * pin 13 (PORTB, bit 5) of the Arduino.
 *
 * The test of your coursework will be against this program (with a
 * different message string) in addition to some manual testing.
 */

// the usual include to get the symbol definitions for ATmega328p
#include <avr/io.h>

// some C macro that help store immutable data in the program memory
#include <avr/pgmspace.h>


// duration of a dot in cs [centiseconds], that is 1/100 of a seconds, 10ms=1cs.
#define DOT 10  

// a dash last three times the length of a dot
#define DASH (3 * DOT) 

// the length of a gap between to Morse signals that belong to the
// same letter:
#define SIGNAL_GAP (DOT) 

// the lenght of a gap between Morse signals to indicate a new letter
// is beginning:
#define LETTER_GAP (3 * DOT)

// the lenght of a gap between Morse signals to indicate a new word
// has begun
#define WORD_GAP (7*DOT)

// make the assembler subrouting in delay.cs known to the C compiler,
// see [1] in the handout.
extern void delay_cs(unsigned char ch);

/**
 * a doubly indexed array of unsigned char that holds the morse codes:
 * the attribute says that the data shall be stored in program memory
 * (and not as usually would be the case in data memory).
 *
 * The encoding of a morse code is in two bytes: The first gives the
 * length of the morse code (ie the number of signals it consists
 * of). The second byte contains the sequence of dots and dashes as a
 * bit pattern, where 1 is a dash and 0 a dot.
 */
unsigned char morse_tab[][2] __attribute__ ((section (".progmem"))) = {
  {2, 0x1}, // A
  {4, 0x8}, // B
  {4, 0xA}, // C
  {3, 0x4}, // D
  {1, 0x0}, // E
  {4, 0x2}, // F
  {3, 0x6}, // G
  {4, 0x0}, // H
  {2, 0x0}, // I
  {4, 0x7}, // J
  {3, 0x5}, // K
  {4, 0x4}, // L
  {2, 0x3}, // M
  {2, 0x2}, // N
  {3, 0x7}, // O
  {4, 0x6}, // P
  {4, 0xD}, // Q
  {3, 0x2}, // R
  {3, 0x0}, // S
  {1, 0x1}, // T
  {3, 0x1}, // U
  {4, 0x1}, // V
  {3, 0x3}, // W
  {4, 0x9}, // X
  {4, 0xB}, // Y
  {4, 0xC}, // Z
};

/**
 * In C, strings are simply defined as an array of char. The attribute
 * again indicated that this string shall be moved into program
 * memory. When defining a string in C below with "" then a zero
 * is added to the string automatically to indicate its end
 * (a so-called zero-terminated string). Characters are encoded as
 * their ASCII values.
 *
 * Change this string to test against a different message (eg one of
 * E,T only or I,A,N,M only etc.
 */
char message[]  __attribute__ ((section (".progmem")))  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; 

/**
 * This function outputs a single *capital* character (in ASCII code) as
 * morse code on pin 13:
 *
 * A function in C is like a free static method in Java.
 *
 * WARNING: As implemented the function only works with *capital
 * letters*. It would be easy to automatically convert small letter to
 * capital ones or check whether the letter provided is indeed a
 * capital letter (and not, say, a number) -- however I refrained from
 * this test or conversion as it would have cluttered the generated
 * machine code even more and make it harder to understand.
 *
 * So do take care that, when you change the string message, it only
 * contains capital letters!
 */
void char2morse(unsigned char ch) {

  /* Convert ASCII code of ch to index into morse_tab, ie 'A' is the
   * first character, so corresponds to index 0
   */
  ch-= 'A'; 

  // get the length of the morse code from morse_tab:
  unsigned char length = pgm_read_byte(&(morse_tab[ch][0]));

  // get the sequence of the morse code
  const unsigned char sequence = pgm_read_byte(&(morse_tab[ch][1])); 

  // prepare a bitmask.
  unsigned char bitmask = (unsigned char) 1 << length;


  // while: is the same as in java
  while(length) {

    PORTB |=_BV(5);  // set bit 5 of PORTB to one (using an or-mask)

    length--; 
    bitmask >>= 1; // shift bitmask right one bit
    
    /*  
     * if: is the same as in Java as well.
     * 
     * We check whether the bit corresponding to bit_mask is set in sequence.
     */
    if(sequence & bitmask) { 
      // bit set: it's a dash
      delay_cs(DASH); // wait
    } else {
      // bit clear: it's a dot
      delay_cs(DOT); // wait
    }

    // switch off bit 5.
    PORTB &= ~(_BV(5)); // end signal
  
    delay_cs(SIGNAL_GAP); // inter signal gap.
  }
 
  delay_cs(LETTER_GAP + SIGNAL_GAP); // inter letter gap, well a bit
				     // extended to be on the save
				     // side :-)
  // delay_cs(3*LETTER_GAP);  // perhaps a longer inter-letter gap is
  // good for testing your program.
}
  
// like a Java program, C also starts at main:
int main(void) {

  // make bit 5, port B an output:
  DDRB |= _BV(5);

  // do forever:
  while(1) {
    
    // for: also essentially the same as in Java -- a bit more
    // cluttered here because we access program memory and do an
    // assignment to letter at the same time as we are checking
    // whether the letter is zero
    unsigned char i;
    unsigned char letter;
    for(i = 0; (letter = pgm_read_byte(&(message[i]))) != 0; i++) {
      char2morse(letter);
    }
	  
  }

  return 0;

}
 

