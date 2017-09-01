:local IP 8.8.8.1
:local COUNT 1

:local radiusMikbill1 0
:local radiusRadCash 1

:local STATUS ([/ping $IP count=$COUNT])

:global statusRadCash

:if ($STATUS = 0) do={

	:if ($statusRadCash = 0) do={
		log warning "enable RadCash"
	
		/ radius disable numbers=$radiusMikbill1
		/ radius enable numbers=$radiusRadCash

		}
	
	:global statusRadCash 1	
	} else {

	:if ($statusRadCash = 1) do={
		log warning "disable RadCash"
	
		/ radius enable numbers=$radiusMikbill1
		/ radius disable numbers=$radiusRadCash

		}
	
	:global statusRadCash 0
	}
