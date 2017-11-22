<?php
class ConvertAction extends Action{
	function index(){
		import("phpQuery");
		$content=file_get_contents("table.txt");
		phpQuery::newDocumentHTML($content);
		$pq=pq();
		$hs=$pq->find("tr");
		
		$ctrlgroup=<<<hello
<div class="control-group">
   <label class="control-label" for="input-name">Name:</label>
   <div class="controls">
      <input type="text" id="input-name" name="dialplan_name">
      <span class="help-block">Please enter an inbound route name</span>
   </div>
</div>
hello;
		$pqform=pq('<form class="form-horizontal"></form>');
		
		foreach ($hs as $h){
			$pqctrlgroup=pq($ctrlgroup);
			$pqh=pq($h);
			$label=$pqh->find("td:eq(0)")->html();
			$pqctrlgroup->find(".control-label")->html($label);
			$controls=$pqh->find("td:eq(1)")->html();
			$pqctrlgroup->find(".controls")->html($controls);
			$pqform->append($pqctrlgroup);
		}
		echo $pqform->html();
		phpQuery::$documents=null;
		
	}
	
	function name(){
		$content=file_get_contents("name.txt");
		echo preg_replace("/name=\"([A-Za-z0-9_]+)\"/", 'name="$1" ng-model="vo.$1"', $content);
	}



}