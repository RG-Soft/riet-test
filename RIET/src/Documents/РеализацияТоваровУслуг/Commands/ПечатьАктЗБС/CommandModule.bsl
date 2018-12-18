
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Если ПроверкиВыполнены(ПараметрКоманды) Тогда 
		УправлениеПечатьюКлиент.ВыполнитьКомандуПечати("Документ.РеализацияТоваровУслуг", "АктЗБС", ПараметрКоманды,
									ПараметрыВыполненияКоманды);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПроверкиВыполнены(Док)
	
	ПроверкиВыполнены = Истина;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	РеализацияТоваровУслугУслуги.НомерСтроки
	               |ИЗ
	               |	Документ.РеализацияТоваровУслуг.Услуги КАК РеализацияТоваровУслугУслуги
	               |ГДЕ
	               |	РеализацияТоваровУслугУслуги.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Док);
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Таблица ""Услуги"" не заполнена!");
		ПроверкиВыполнены = Ложь;
	КонецЕсли;

	Возврат ПроверкиВыполнены;
	
КонецФункции