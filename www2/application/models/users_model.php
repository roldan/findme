<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class users_model extends CI_Model {
	public function __construct (){
		$this->load->database();
	}
	public function exists (){
		$fbID = $this->input->get('fbID');
		$query = $this->db->get_where('users', array('fbID' => $fbID));
		$num = 0;
		foreach ($query->result() as $row){
			$num++;
		}
		if ($num > 0){
			return true;
		}
		return false;
	}
	public function create(){
		$fbID = $this->input->post('fbID');
		$hash = substr (md5 ($fbID),0,6 );
		$data = array(
			'fbID' => $fbID ,
			'hash' => $hash ,
			'puntos' => 0
		);
		$this->db->insert('users', $data);
		return $hash;
	}
	public function check(){
		$fbID = $this->input->get('fbID');
		$hash = $this->input->get('hash');
		$query = $this->db->get_where('users', array('fbID' => $fbID, 'hash' => $hash));
		$num = 0;
		foreach ($query->result() as $row){
			$num++;
		}
		if ($num > 0){
			return true;
		}
		return false;
	}
	private function prevPoints ($fbID){
		$query = $this->db->get_where('users', array('fbID' => $fbID));
		$row = $query->result();
		return $row[0]->puntos;
	}
	public function addPoints (){
	
		$add =  $this->input->post('add');
		$fbID = $this->input->post('fbID');
		$puntos = prevPoints ($fbID);
		$data = array(
			'puntos' => $add+$puntos,
        );

		$this->db->where('fbID', $fbID);
		$this->db->update('mytable', $data); 

	}
	public function get (){
		$fbID = $this->input->get('fbID');
		$query = $this->db->get_where('users', array('fbID' => $fbID));
		$row = $query->result();
		return $row [0];
	}
}

/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */