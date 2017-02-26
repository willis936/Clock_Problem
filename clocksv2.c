/*==============================================================*/
/* AUTHOR:
 *      Paul Willis
 * DATE:
 *      2/7/13
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
#include <time.h>
#define MAX_SEC 43200
#define MAX_ANS 22
#define ROTATION 60.0
#define PAC_POW 5

typedef enum {false, true} bool;

typedef struct
{
    double sec,
           min,
           hrs;
} time_Day;

time_Day update_time(time_Day sample, double step);
time_Day angle(time_Day sample);
bool test_time(time_Day angle, double tolerance);
bool test_angle(double angle1, double angle2, double tolerance);
void print_time(time_Day sample);
int pacifier(int working);
void results_out(time_t start, time_t end, FILE *results, time_Day answers[]);
void write_time(time_Day sample, FILE *results);

int main (void)
{
    int i = 0,
        j = 0,
        k = 0;
    double tolerance = 1,
           step = .0005;
    time_Day day = {0, 0, 0},
             night = {MAX_SEC - step, 720, 12},
             answers[MAX_ANS],
             answers_2[MAX_ANS];
    time_t start,
           end;
    FILE *results;
    results = fopen("results.txt", "w");

    /* Print greeting */
    printf("\nHello,\n");
    printf("\tThis program calculates and prints approximate "
        "times at\n\twhich the second, minute, and hour hands are"
        " all equal\n\tparts away from each other on a clock "
        "face.\n\tAccurate to %g seconds.\n", step * 2);

    /* Store starting time */
    time(&start);

    /* Calculate critical times forward */
    while (day.sec < MAX_SEC - step)
    {
        /* Update times */
        day = update_time(day, step);

        /* Test if critical time */
        if (test_time(angle(day), tolerance))
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
    while (night.sec > 0)
    {
        /* Update times */
        night = update_time(night, -step);

        /* Test if critical time */
        if (test_time(angle(night), tolerance))
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

    /* Store ending time */
    time(&end);

    /* Print critical times */
    printf("\n\tAnswers:\n");
    for (i = 0; i < MAX_ANS; i++)
    {
        printf("%2d:", i + 1);
        print_time(answers[i]);
    }

    /* Store critical times */
    fprintf(results, "\tThis is an approximation of the times at"
        "\n\twhich the second, minute, and hour hands\n\tare"
        " all equal parts away from each other\n\ton a clock "
        "face.\n\n\tAccurate to %g seconds.\n", step * 2);
    fprintf(results, "\n\tsystem time: %s", ctime(&end));
    fprintf(results, "\n\t%d iterations completed.\n", k);
    results_out(start, end, results, answers);

    /* Print farewell */
    printf("\nGoodbye.\n\n");
    system("PAUSE");
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
time_Day update_time(time_Day sample, double step)
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
 time_Day angle(time_Day sample)
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
bool test_time(time_Day angle, double tolerance)
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
void print_time(time_Day sample)
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

/*==============================================================*/
/* Builds results text file.
 * Inputs:
 *      start -- system time at beginning of prog
 *      end -- system time at end of prog
 * Outputs:
 * Side-effects: builds text file and writes results
 *==============================================================*/
void results_out(time_t start, time_t end, FILE *results, time_Day answers[])
{
    int i;

    time_t difference = end - start;

    /* Write critical times */
    fprintf(results, "\n\tcompute time: %1d seconds\n", difference);
    fprintf(results, "\n\tAnswers:\n");
    for (i = 0; i < MAX_ANS; i++)
    {
        fprintf(results, "%2d:", i + 1);
        write_time(answers[i], results);
    }
    printf("\nResults stored in results.txt\n");
    return;
}

/*==============================================================*/
/* Writes the time in a neat manner.
 * Inputs:
 *      sample -- struct containing hrs, min, and sec
 * Outputs: NONE
 * Side-effects: writes time to text
 *==============================================================*/
void write_time(time_Day sample, FILE *results)
{
    /* Displays 0 hours as 12 */
    if (sample.hrs < 1)
    {
        sample.hrs += 12;
    }
    fprintf(results, "\t%2d: %02d: %06.6f\n", (int) sample.hrs,
        (int) sample.min % 60, fmod(sample.sec, 60.0));
    fflush(stdout);
    return;
}
