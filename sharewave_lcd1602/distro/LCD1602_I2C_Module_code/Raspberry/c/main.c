#include "lcd1602_Module.h"
int main()
{
    LCD1602_init(16,2);
    while(1)
    {
        setCursor(0,0);
        send_string("Waveshare");
        setCursor(0,1);
        send_string("Hello World!");
    }
    return 0;
}
