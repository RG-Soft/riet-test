
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Параметры.РежимВыбора Тогда
		Элементы.СписокКнопкаВыбрать.Видимость = Истина;
		Элементы.СписокКнопкаВыбрать.КнопкаПоУмолчанию = Истина;
	Иначе
		Элементы.СписокКнопкаВыбрать.Видимость = Ложь;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СписокПриИзменении(Элемент)
	Оповестить("Запись_ПерепискаСКонтролирующимиОрганами", , Элемент.ТекущаяСтрока);
КонецПроцедуры
