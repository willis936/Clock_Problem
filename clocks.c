/*==============================================================*/
/* AUTHOR:
 *      Paul Willis
 * DATE:
 *      4/14/12 - 4/16/12
 * PURPOSE:
 *      This program calculates and prints approximate times at
 *      which the second, minute, and hour hands are all equal
 *      parts away from each other on a clock face.
 * INPUT:
 *      NONE
 * OUTPUT:
 *      Prints a greeting, pacifier, answer set, and farewell to
 *      the screen.
 *==============================================================*/
#include <math.h>
#include <stdio.h>
#define MAX_SEC 43200
#define MAX_ANS 22
#define ROTATION 60.0
#define PAC_POW 6       /* Changes pacifier rate */

typedef enum {false, true} bool;

typedef struct
{
    double sec,
           min,
           hrs;
} time;

time update_time(time sample, double step);
time update_angle(time sample);
bool test_time(time angle, double tolerance);
bool test_angle(double angle1, double angle2, double tolerance);
void print_time(time sample);
int pacifier(int working);

int main (void)
{
    int i = 0,
        j = 0,
        k = 0;
    double tolerance = 1,
           step = .0005;
    time day = {0, 0, 0},
         night = {MAX_SEC, 720, 12},
         answers[MAX_ANS],
         answers_2[MAX_ANS];
    
    /* Print greeting */
    printf("\nHello,\n");
    printf("\tThis program calculates and prints approximate "
        "times at\n\twhich the second, minute, and hour hands are"
        " all equal\n\tparts away from each other on a clock "
        "face.\n\tAccurate to %g seconds.\n", step * 2);
    
    /* Calculate critical times forward */
    while (day.sec < MAX_SEC - step)
    {
        /* Update times */
        day = update_time(day, step);
        
        /* Test if critical time */
        if (test_time(update_angle(day), tolerance))
        {
            /* Store critical time */
            answers[j] = day;
            j++;
            /* Step out of tolerance to avoid repeat answers */
            day = update_time(day, 300);
            /* Check if max answers has been reached */
            if (j > MAX_ANS)
            {
                day = update_time(day, MAX_SEC);
                printf("\nMAX ANSWERS REACHED, "
                    "EXITING LOOP.");
            }
        }
        /* Pacifier */
        i = pacifier(i);
        k++;
    }
    
    /* Calculate critical times backward */
    while (night.sec > step)
    {
        /* Update times */
        night = update_time(night, -step);
        
        /* Test if critical time */
        if (test_time(update_angle(night), tolerance))
        {
            /* Store critical time */
            answers_2[j - 1] = night;
            j--;
            /* Step out of tolerance to avoid repeat answers */
            night = update_time(night, -300);
        }
        /* Pacifier */
        i = pacifier(i);
        k++;
    }
    
    /* Print statistics */
    printf("\n\n  %d iterations completed.\n", k);
    
    /* Average critical times */
    for (i = 0; i < MAX_ANS; i++)
    {
        answers[i].sec += answers_2[i].sec - answers[i].sec;
        answers[i].min += answers_2[i].min - answers[i].min;
        answers[i].hrs += answers_2[i].hrs - answers[i].hrs;
    }
    
    /* Print critical times */
    printf("\n\tAnswers:\n");
    for (i = 0; i < MAX_ANS; i++)
    {
        printf("%2d:", i + 1);
        print_time(answers[i]);
    }
    
    /* Print farewell */
    printf("\nGoodbye.\n");
    return 0;
}

/*==============================================================*/
/* Steps the time forward
 * Inputs:
 *      sample -- struct containing hrs, min, and sec
 *      step -- amount of time to step forward
 * Outputs: 
 *      stepped time
 * Side-effects: NONE
 *==============================================================*/
time update_time(time sample, double step)
{
    sample.sec += step;
    sample.min += step / 60.0;
    sample.hrs += step / 3600.0;
    return sample;
}

/*==============================================================*/
/* Updates the angles of clock hands
 * Inputs:
 *      angle -- struct containing angles of hrs, min, and sec
 * Outputs: 
 *      updated hand positions
 * Side-effects: NONE
 *==============================================================*/
time update_angle(time sample)
{
    sample.sec = (ROTATION / 60.0) * fmod(sample.sec, 60.0);
    sample.min = (ROTATION / 60.0) * fmod(sample.min, 60.0);
    sample.hrs = (ROTATION / 12.0) * sample.hrs;
    return sample;
}
/*==============================================================*/
/* Performs series of tests comparing hand angles
 * Inputs:
 *      angle -- struct containing angles of hrs, min, and sec
 *      tolerance -- tolerance for test
 * Outputs: 
 *      bool of angle test
 * Side-effects: NONE
 *==============================================================*/
bool test_time(time angle, double tolerance)
{
    return (test_angle(angle.sec, angle.min, tolerance) *
            test_angle(angle.min, angle.hrs, tolerance) *
            test_angle(angle.hrs, angle.sec, tolerance));
}

/*==============================================================*/
/* Performs a single test comparing two hand angles
 * Inputs:
 *      angle1 -- double of one angle
 *      angle2 -- double of another angle
 *      tolerance -- tolerance for test
 * Outputs: 
 *      bool of individual angle comparison
 * Side-effects: NONE
 *==============================================================*/
bool test_angle(double angle1, double angle2, double tolerance)
{
    return
    ((fabs(angle1 - angle2) < ((ROTATION / 3.0) +
        tolerance / 2.0) &&
    fabs(angle1 - angle2) > ((ROTATION / 3.0) -
        tolerance / 2.0)) ||
    (fabs(angle1 - angle2) < ((ROTATION * 2.0 / 3) +
        tolerance / 2.0) &&
    fabs(angle1 - angle2) > ((ROTATION * 2.0 / 3) -
        tolerance / 2.0)));
}

/*==============================================================*/
/* Prints out the time in a neat manner.
 * Inputs:
 *      sample -- struct containing hrs, min, and sec
 * Outputs: NONE
 * Side-effects: prints time to screen
 *==============================================================*/
void print_time(time sample)
{
    /* Displays 0 hours as 12 */
    if (sample.hrs < 1)
    {
        sample.hrs += 12;
    }
    printf("\t%2d: %02d: %06.3f\n", (int) sample.hrs,
        (int) sample.min % 60, fmod(sample.sec, 60.0));
    fflush(stdout);
    return;
}

/*==============================================================*/
/* Counts up and prints pacifier at regular intervals.
 * Inputs:
 *      working -- counter for pacifier
 * Outputs: 
 *      working + 1
 * Side-effects: prints pacifier to screen
 *==============================================================*/
int pacifier(int working)
{
    if (working == pow(1 * 10, PAC_POW))
    {
        printf("\n  WORKING");
        fflush(stdout);
    }
    else if (working == 5 * pow(10, PAC_POW) ||
        working == 9 * pow(10, PAC_POW) ||
        working == 13 * pow(10, PAC_POW) ||
        working == 17 * pow(10, PAC_POW) ||
        working == 21 * pow(10, PAC_POW) ||
        working == 25 * pow(10, PAC_POW))
    {
        printf(".");
        fflush(stdout);
    }
    else if (working > 25 * pow(10, PAC_POW))
    {
        working = -3 * pow(10, PAC_POW);
    }
    return ++working;
}
