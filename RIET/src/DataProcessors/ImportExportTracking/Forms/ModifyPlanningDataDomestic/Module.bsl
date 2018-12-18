
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("Comments") Тогда
		Comments = Параметры.Comments;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ProjectMobilizationПриИзменении(Element)
	
	// set "modify" field if main value is changed
	elementName = Element.Name;
	
	modifyElement = elementName + "_modify";
	
	thisForm[modifyElement] = true;
	
КонецПроцедуры

&НаКлиенте
Процедура OK(Команда)
	
	Close(getParams());
	
КонецПроцедуры

&НаСервере
Функция getParams()
	
	clsParams = new Structure;
	
	// fill the structure and return it
	
	namesArray = new Array;
	namesArray.Add("ProjectMobilization");
	namesArray.Add("LocationFrom");
	namesArray.Add("LocationTo"); 
	namesArray.Add("MOT");
	namesArray.Add("Equipment");
	namesArray.Add("Company");
	namesArray.Add("HazardClass");
	namesArray.Add("Qty");
	namesArray.Add("GrossWeightKG");
	namesArray.Add("FreightCostPerKG");
	namesArray.Add("Comments");
	        		
	Для каждого curName из namesArray Цикл
		
		if (thisForm[curName + "_modify"]) then
						
			realName = curName;
						
			Если realName = Неопределено Тогда
				realName = curName;
			КонецЕсли;
			
			clsParams.Вставить(realName, thisForm[curName]);
						
		EndIf;
		
	КонецЦикла;
	
	return clsParams;
	
КонецФункции


