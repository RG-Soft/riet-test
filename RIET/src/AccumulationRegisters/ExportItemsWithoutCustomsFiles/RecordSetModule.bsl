
Процедура ДобавитьЗапись(ВидДвижения, Период, Item, ExportRequest, ExportShipment) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ВидДвижения) Тогда
		ВызватьИсключение "Вид движения is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Период) Тогда
		ВызватьИсключение "Период is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Item) Тогда
		ВызватьИсключение "Item is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ExportRequest) Тогда
		ВызватьИсключение "Export request is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ExportShipment) Тогда
		ВызватьИсключение "Export shipment is empty!";
	КонецЕсли;
	
	Движение = Добавить();
	Движение.ВидДвижения = ВидДвижения;
	Движение.Период = Период;
	Движение.Item = Item;	
	Движение.ExportRequest = ExportRequest;
	Движение.ExportShipment = ExportShipment;	
	Движение.Ресурс = 1;
	
КонецПроцедуры