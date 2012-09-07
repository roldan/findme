<?php
	
	$dict = array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
	
	for ($i = 65; $i < 91; $i++) {
		array_push($dict, chr($i));
	}
	
	for ($i = 97; $i < 123; $i++) {
		array_push($dict, chr($i));
	}
	
	function idToHash($id) {
		
		$i = 0;
		
		$d1 = 0; $d2 = 0; $d3 = 0; $d4 = 0; $d5 = 0;
		
		global $dict;
		
		while ($i < $id) {
			
			$d5++;
			
			if ($d5 == 61) {
				$d4++;
				$d5 = 0;
			}
			if ($d4 == 61) {
				$d3++;
				$d4 = 0;
			}
			if ($d3 == 61) {
				$d2++;
				$d3 = 0;
			}
			if ($d2 == 61) {
				$d1++;
				$d2 = 0;
			}
			
			$i++;
		}
		
		echo $dict[$d1].$dict[$d2].$dict[$d3].$dict[$d4].$dict[$d5];
	}
	
	echo idToHash(100000000);
	
?>