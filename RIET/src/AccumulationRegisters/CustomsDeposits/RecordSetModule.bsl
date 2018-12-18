
Процедура ДобавитьЗапись(ВидДвижения, Период, CustomsBond, Sum) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ВидДвижения) Тогда
		ВызватьИсключение "Вид движения is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Период) Тогда
		ВызватьИсключение "Период is empty!";
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(CustomsBond) Тогда
		ВызватьИсключение "Customs bond is empty!";
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Sum) Тогда
		ВызватьИсключение "Sum is empty!";
	КонецЕсли;

	Движение = Добавить();
	Движение.ВидДвижения = ВидДвижения;
	Движение.Период = Период;
	Движение.CustomsBond = CustomsBond;
	Движение.Sum = Sum;
	
КонецПроцедуры