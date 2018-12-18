
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
	namesArray.Add("POD");
	namesArray.Add("POA");
	namesArray.Add("MOT");
	namesArray.Add("HazardClass");
	namesArray.Add("Qty");
	namesArray.Add("Value");
	namesArray.Add("GrossWeightKG");
	namesArray.Add("FreightCostPerKG");
	namesArray.Add("Comments");
	
	СоответствиеИмен = Новый Соответствие;
	СоответствиеИмен.Вставить("POA", "RequestedPOACode");
	СоответствиеИмен.Вставить("POD", "PODCode");
	СоответствиеИмен.Вставить("MOT", "MOTCode");
	
	Для каждого curName из namesArray Цикл
		
		if (thisForm[curName + "_modify"]) then
			
			
			realName = curName;
			
			// names mapping
			Если НЕ СоответствиеИмен = Неопределено Тогда
				realName = СоответствиеИмен.Получить(curName);
			КонецЕсли;
			
			Если realName = Неопределено Тогда
				realName = curName;
			КонецЕсли;
			
			if (curName = "POA" OR curName = "POD" OR curName = "MOT") Then
				clsParams.Вставить(realName, thisForm[curName].Code);
			else
				clsParams.Вставить(realName, thisForm[curName]);
			EndIf;
			
		EndIf;
		
	КонецЦикла;
	
	return clsParams;
	
КонецФункции

