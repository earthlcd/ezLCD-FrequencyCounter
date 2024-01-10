----------------------------------------------------------------------
-- ezLCD Frequency Counter test application note example
--
-- Created  01/10/2024 -  Jacob Christ
--
-- This program has tested on the following:
--   ezLCD-5035 Firmware 01042024 - Needed for sub second os.clock()
--
----------------------------------------------------------------------

-- Valid interruptable pins:
-- GPIO_PIN_0, GPIO_PIN_2, GPIO_PIN_3, GPIO_PIN_5, GPIO_PIN_10

FREQ_Pin = 2
EDGE_Count = 0
EDGE_Last = 0
EDGE_This = 0
PERIOD = 0;

function MyInterrupt(pin_no)
	EDGE_This = os.clock()
	PERIOD = EDGE_This - EDGE_Last
	EDGE_Last = EDGE_This

	EDGE_Count = EDGE_Count + 1
end


function MainFunction()
	ez.SetPinInp(FREQ_Pin,true,false) -- GPIO: DIGITAL PULSE (FREQ) IN: CONFIGURES THE I/O PIN AS DISCRETE INPUT, (PULL-UP) & PULL-DOWN BOTH DISABLED (DEFAULT)
	-- Assign on change interrupt to pin 1
	ez.SetPinIntr(FREQ_Pin, "MyInterrupt", 1) -- 1 = Rising edge only

	ez.Cls(ez.RGB(0,0,0))
	ez.SetColor(ez.RGB(0,0,255))
	ez.SetXY(0,0)
	print(string.format("EarthLCD Frequency Counter Example"))

	while (1) do
		local color = 64
		local x1 = 0
		local x2 = 200
		local y1 = 20
		local y2 = 50

		ez.BoxFill(x1,y1, x2,y2, ez.RGB(color,color,color)) -- X1, Y1, X2, Y2, Color

		ez.SetXY(x1,y1+3)
		ez.SetColor(ez.RGB(255,255,255))
		print(string.format("   EDGE_Count %d", EDGE_Count))
		print(string.format("   PERIOD %f", PERIOD))
		print(string.format("   FREQENCY %f", 1/PERIOD))

		ez.Wait_ms(250)
	end
	
end

function ErrorHandler(errmsg)
    print(debug.traceback())
    print(errmsg)
end

-- Call mainFunction() protected by errorHandler
rc, err = xpcall(function() MainFunction() end, ErrorHandler)
