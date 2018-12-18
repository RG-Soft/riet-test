
Процедура ДобавитьЗапись(Период, Item, ProcessLevel, Regime, CCAJobReference=Неопределено, ShipperName=Неопределено) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Период) Тогда
		ВызватьИсключение "Период is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Item) Тогда
		ВызватьИсключение "Item is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ВызватьИсключение "Process level is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Regime) Тогда
		ВызватьИсключение "Regime is empty!";
	КонецЕсли;
	
	Движение = Добавить();
	Движение.Период = Период;
	Движение.Item = Item;
	Движение.ProcessLevel = ProcessLevel;
	Движение.CustomsRegime = Regime;
	Движение.CCAJobReference = CCAJobReference;
	Движение.ShipperName = ShipperName;
	
КонецПроцедуры