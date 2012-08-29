<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class users extends CI_Controller {
	
	public function __construct()
	{
		parent::__construct();
		$this->load->model('users_model');
		$this->output->set_content_type('application/json');
		
	}

	public function exists (){
		if ($this->users_model->exists()){
			$data = array ('exists' => true);
			echo json_encode ($data);
		}
	}
	
	public function create (){
		if ($this->users_model->exists()){
			$data = array (
				'exists' => true
			);
			echo json_encode ($data);
		}
		else{
			$hash = $this->users_model->create();
			$data = array (
				'exists' => false,
				'hash' => $hash
			);
			echo json_encode ($data);
		}
	}
	public function check (){
		$data = array(
			'check' => $this->users_model->check()
		);
		echo json_encode ($data);
	}
	public function addPoints (){
		$this->users_model->addPoints();
		return json_encode (array('updated' => true));
	}
	public function get(){
		$data = $this->users_model->get();
		return json_encode ($data);
	}
}

/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */