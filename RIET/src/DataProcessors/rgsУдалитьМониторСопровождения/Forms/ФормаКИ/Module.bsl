
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Попытка
		Определение = Новый WSОпределения(Параметры.Объект.АдресБазы+"/ws/Tasks.1cws?wsdl",  Параметры.Объект.Пользователь,  Параметры.Объект.Пароль);
		Прокси = Новый WSПрокси (Определение, "http://www.1c.ru/docmng", "ЗадачиПользователя", "ЗадачиПользователяSoap");
		Прокси.Пользователь =  Параметры.Объект.Пользователь;
		Прокси.Пароль		= Параметры.Объект.Пароль; 
		ТаблицаКИ.Загрузить(ЗначениеИзСтрокиВнутр(Прокси.ПолучитьТаблицуКИУчастниковОбсужденияВопроса(Параметры.ГУИДВопроса)));
	Исключение
		Сообщить(ОписаниеОшибки()); 
		Возврат;
	КонецПопытки; 
	
КонецПроцедуры
