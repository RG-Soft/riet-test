&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ПолноеИмяФайлаОтправки = Параметры.ПолноеИмяФайлаОтправки;
	ИнформационноеСообщение = "Для отправки файла выгрузки требуется предварительно сохранить его по адресу:
	|" + ПолноеИмяФайлаОтправки;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПодключитьОбработчикОжидания("ОжиданиеПередОтправкой", 10);
	
КонецПроцедуры

&НаКлиенте
Процедура ОжиданиеПередОтправкой()
	//попытка найти файлы, готовые к отправке
	ФайлОтправки = Новый Файл(ПолноеИмяФайлаОтправки);
	Если ФайлОтправки.Существует() Тогда
		ОтключитьОбработчикОжидания("ОжиданиеПередОтправкой");
		//закрываем форму, переходя к отправке
		Закрыть(Истина);
	КонецЕсли;	
КонецПроцедуры