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
	-- This interrupt is fired when there is a change on the pin we are trying to measure the frequency of.

	EDGE_This = os.clock() -- Get the current time
	EDGE_Delta = EDGE_This - EDGE_Last -- Calculate the delta time since the last edge

	-- Becuase our timer (os.clock()) resolution is only 1ms we can't time periods less than 1ms.  Instead we count edges
	-- over a longer period of time and then average the period by the number of edges.
	-- if more than 1 second has gone by since the detected the first edge we are ready to calculate the period
	if EDGE_Delta > 1.00 then 
		EDGE_Last = EDGE_This
		if EDGE_Count > 0 then
			-- If we have seen more than one edge then we divide the EDGE_Delta by the EDGE_Count to find the period
			PERIOD = EDGE_Delta / (EDGE_Count + 1)
		else
			-- If we have only seen the first edge in more than one second then we will use EDGE_Delta for our period
			PERIOD = EDGE_Delta
		end
		-- This is a low pass filter that uses 95% of our current measurment with 5% of our old average
		PERIOD_AVERAGE = PERIOD_AVERAGE * 0.05 + PERIOD * 0.95
		-- reset the edge count to zero
		EDGE_Count = 0
	else
		EDGE_Count = EDGE_Count + 1
	end

end

function DisplayHeader()
	ez.Cls(ez.RGB(0, 0, 0))
	ez.BoxFill(0, 0, ez.Width, 40, ez.RGB(64,64,64)) -- X1, Y1, X2, Y2, Color

	ez.SetFtFont(6,18,18)
	ez.SetColor(ez.RGB(255,255,255))
	ez.SetXY(0,10)
	print(string.format(" EarthLCD Frequency Counter"))
end

function MainFunction()
	local next_refresh = 0.0 -- This variable keeps track of the next screen refreash time

	-- The next two lines configure the interrupt pin
	ez.SetPinInp(FREQ_Pin,true,false) -- GPIO: DIGITAL PULSE (FREQ) IN: CONFIGURES THE I/O PIN AS DISCRETE INPUT, (PULL-UP) & PULL-DOWN BOTH DISABLED (DEFAULT)

	-- Assign on change interrupt
	-- ez.SetPinIntr(PinNo, LuaFunction [, edgeSelect [, pullUp [, pullDn]]])
	-- edgeSelect
	--   0 = Rising and Falling Edge (default)
	--   1 = Rising Edge Only
	--   2 = Falling Edge Only
	-- pullUp / pullDown
	--   true/false
	ez.SetPinIntr(FREQ_Pin, "MyInterrupt", 1)

	-- Display the program header
	DisplayHeader()

	while (1) do

		-- Check if enought time has gone by so that we can refresh the screen
		if os.clock() > next_refresh then
			local x1 = 0
			local x2 = ez.Width
			local y1 = 90
			local y2 = y1 +100

			-- Erase the old measurements
			ez.BoxFill(x1,y1, x2,y2, ez.RGB(0, 0, 0)) -- X1, Y1, X2, Y2, Color

			-- Position the cursor to where we are going to start drawing our measurements
			ez.SetXY(x1,y1+20)
			-- Set the forground (text) color
			ez.SetColor(ez.RGB(255,255,0))
			-- Display the average frequency
			print(string.format("   FREQENCY %0.2f Hz", 1/PERIOD_AVERAGE))
			ez.SetColor(ez.RGB(0,255,255))
			-- Display the average period
			print(string.format("   PERIOD %f sec", PERIOD_AVERAGE))
			ez.SetColor(ez.RGB(255,0,255))
			-- Display edge count (for sub second pulses)
			print(string.format("   EDGE_Count %d", EDGE_Count))
	
			--ez.Wait_ms(250) -- Addeing this delay prevents measurements of periods less than the delay period
			next_refresh = os.clock() + 0.25
		end
	end
	
end

function ErrorHandler(errmsg)
    print(debug.traceback())
    print(errmsg)
end

-- Call mainFunction() protected by errorHandler
rc, err = xpcall(function() MainFunction() end, ErrorHandler)
