
Процедура ДобавитьЗапись(ВидДвижения, Период, CustomsReceiptOrder, PaymentKind=Неопределено, Sum) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ВидДвижения) Тогда
		ВызватьИсключение "Вид движения is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Период) Тогда
		ВызватьИсключение "Период is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(CustomsReceiptOrder) Тогда
		ВызватьИсключение "Customs receipt order is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Sum) Тогда
		ВызватьИсключение "Sum is empty!";
	КонецЕсли;
	
	Движение = Добавить();
	Движение.ВидДвижения = ВидДвижения;
	Движение.Период = Период;
	Движение.ТПО = CustomsReceiptOrder;
	Движение.PaymentKind = PaymentKind;
	Движение.Sum = Sum;
	
КонецПроцедуры
