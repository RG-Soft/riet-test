
&НаКлиенте
Процедура LabelПриИзменении(Элемент)
	
	УстановитьОтборНаСписок();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОтборНаСписок()
	
	Список.Отбор.Элементы.Очистить();
	ЭлементОтбораДанных = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
    ЭлементОтбораДанных.ЛевоеЗначение		= Новый ПолеКомпоновкиДанных("Label");
    ЭлементОтбораДанных.Использование		= Истина;
    ЭлементОтбораДанных.ВидСравнения        = ВидСравненияКомпоновкиДанных.Равно;            
    ЭлементОтбораДанных.ПравоеЗначение		= LabelHeader;
	
	Элементы.Code.Видимость = (LabelHeader <> "Charge type code desc");

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если LabelHeader = "" Тогда
	    LabelHeader = "UOM";
	КонецЕсли; 
	УстановитьОтборНаСписок();
	
КонецПроцедуры

