<?php

	$all32 = array("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V");
	
	function base32_encode($int) {
		
		$d1 = 0; $d2 = 0; $d3 = 0; $d4 = 0;
		
		$i = 0;
		
		global $all32;
		
		while ($i < $int) {
			
			$d4++;
			if ($d4 == 31) {
				$d4 = 0;
				$d3++;
			}
			if ($d3 == 31) {
				$d3 = 0;
				$d2++;
			}
			if ($d2 == 31) {
				$d2 = 0;
				$d1++;
			}
			
			$i++;
		}
		
		echo $all32[$d1].$all32[$d2].$all32[$d3].$all32[$d4];
		
	}
	
	base32_encode(95299);

?>