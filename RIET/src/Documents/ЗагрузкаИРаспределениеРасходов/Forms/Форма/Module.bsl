
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	FA = Истина;
	MS = Истина;
	Taxes = Истина;
	Inventory = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ОК(Команда)
	ПараметрыЗакрытия = Новый Структура("FA, Inventory, MS, Taxes", FA, Inventory, MS, Taxes);
	Закрыть(ПараметрыЗакрытия);
КонецПроцедуры


