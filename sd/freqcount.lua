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
EDGE_Count_Last = 0
EDGE_Count = 0
EDGE_Last = 0
EDGE_This = 0
PERIOD = 0;
PERIOD_AVERAGE = 0;

function MyInterrupt(pin_no)
	EDGE_This = os.clock()
	EDGE_Delta = EDGE_This - EDGE_Last

	if EDGE_Delta > 1.00 then
		EDGE_Last = EDGE_This
		if EDGE_Count > 0 then
			PERIOD = EDGE_Delta / EDGE_Count
		else
			PERIOD = EDGE_Delta
		end
		PERIOD_AVERAGE = PERIOD_AVERAGE * 0.2 + PERIOD * 0.8
		EDGE_Count = 0
	else
		EDGE_Count = EDGE_Count + 1
	end

end


function MainFunction()
	local background_color = ez.RGB(0, 0, 0)
	ez.SetPinInp(FREQ_Pin,true,false) -- GPIO: DIGITAL PULSE (FREQ) IN: CONFIGURES THE I/O PIN AS DISCRETE INPUT, (PULL-UP) & PULL-DOWN BOTH DISABLED (DEFAULT)
	-- Assign on change interrupt to pin 1
	ez.SetPinIntr(FREQ_Pin, "MyInterrupt", 1) -- 1 = Rising edge only

	ez.Cls(ez.RGB(0, 0, 0))
	ez.BoxFill(0, 0, ez.Width, 40, ez.RGB(64,64,64)) -- X1, Y1, X2, Y2, Color

	ez.SetFtFont(6,18,18)
	ez.SetColor(ez.RGB(255,255,255))
	ez.SetXY(0,10)
	print(string.format(" EarthLCD Frequency Counter"))

	while (1) do
		local x1 = 0
		local x2 = ez.Width
		local y1 = 90
		local y2 = y1 +100

		ez.BoxFill(x1,y1, x2,y2, ez.RGB(0, 0, 0)) -- X1, Y1, X2, Y2, Color

		ez.SetXY(x1,y1+20)
		ez.SetColor(ez.RGB(255,255,0))
		print(string.format("   FREQENCY %0.2f Hz", 1/PERIOD_AVERAGE))
		ez.SetColor(ez.RGB(0,255,255))
		print(string.format("   PERIOD %f sec", PERIOD_AVERAGE))
		ez.SetColor(ez.RGB(255,0,255))
		print(string.format("   EDGE_Count %d", EDGE_Count))

		--ez.Wait_ms(250) -- Addeing this delay prevents measurements of periods less than the delay period
	end
	
end

function ErrorHandler(errmsg)
    print(debug.traceback())
    print(errmsg)
end

-- Call mainFunction() protected by errorHandler
rc, err = xpcall(function() MainFunction() end, ErrorHandler)
