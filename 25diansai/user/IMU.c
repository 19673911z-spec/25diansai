#include "headfile.h"

volatile uint8_t imu_flag;
uint8_t orginal_data;
double yaw_angle;
volatile int yaw_angle_int;
struct Angle YawAngle;

void imu_init(void)
{
    uart_init(UART0, 9600, 1);
}

void imu_uart_callback(void)
{
    static unsigned char imu_rx_buffer[250];
    static unsigned char counter = 0;

    orginal_data = uart_getbyte(UART0);
    imu_rx_buffer[counter++] = orginal_data;

    if(imu_rx_buffer[0] != 0x55)
    {
        counter = 0;
        return;
    }

    if(counter < 11)
    {
        return;
    }

    if(imu_rx_buffer[1] == 0x53)
    {
        memcpy(&YawAngle, &imu_rx_buffer[2], 8);
        imu_flag = 1;
    }

    counter = 0;
}

void imu_analysis(void)
{
    yaw_angle = (float)YawAngle.Angle[2] / 32768 * 180;
    yaw_angle_int = (int)yaw_angle;
}
