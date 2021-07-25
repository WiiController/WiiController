//
//  WiimoteProtocolHeroGuitar.h
//  Wiimote
//

typedef enum
{
    WiimoteDeviceHeroGuitarReportButtonMaskUp = 0x0001,
    WiimoteDeviceHeroGuitarReportButtonMaskYellow = 0x0008,
    WiimoteDeviceHeroGuitarReportButtonMaskGreen = 0x0010,
    WiimoteDeviceHeroGuitarReportButtonMaskBlue = 0x0020,
    WiimoteDeviceHeroGuitarReportButtonMaskRed = 0x0040,
    WiimoteDeviceHeroGuitarReportButtonMaskOrange = 0x0080,
    WiimoteDeviceHeroGuitarReportButtonMaskPlus = 0x0400,
    WiimoteDeviceHeroGuitarReportButtonMaskMinus = 0x1000,
    WiimoteDeviceHeroGuitarReportButtonMaskDown = 0x4000,
} WiimoteDeviceHeroGuitarReportButtonMask;

typedef struct
{
    struct {
        int : 2;
        int pos : 6;
    } stickX, stickY;
    struct {
        int : 3;
        int value : 5;
    } touchBar, whammyBar;
    /// Big-endian!
    uint16_t buttonState;
} WiimoteDeviceHeroGuitarReport;
