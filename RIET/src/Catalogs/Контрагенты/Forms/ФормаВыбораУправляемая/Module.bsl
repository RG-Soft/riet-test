
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЭлементОформления=Список.УсловноеОформление.Элементы.Добавить();
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ДатаЗапретаИспользования");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Больше;
	ЭлементОтбора.Использование = Истина;
	ЭлементОтбора.ПравоеЗначение = Дата(1,1,1);
	
	//цвет текста строки  
	Элемент = ЭлементОформления.Оформление.Элементы[1];
	Элемент.Использование = Истина;                                                     
	Элемент.Значение = Новый Цвет(255,0,0);
	
КонецПроцедуры





