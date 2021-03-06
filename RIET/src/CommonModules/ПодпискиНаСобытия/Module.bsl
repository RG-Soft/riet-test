
/////////////////////////////////////////////////////////////////////////////////////
// ПРАВА ДОСТУПА

//ДУМАТЬ!!!
Процедура ПередЗаписьюОбъектаПравДоступа(Источник, Отказ) Экспорт
	
	//ДУМАТЬ!!!
	Если Источник.ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
		
	Источник.ПрошлыйИзмененныйРодительОбъектаДоступа = ?(Не Источник.ЭтоНовый() и Не Источник.Ссылка.Родитель = Источник.Родитель, Источник.Ссылка.Родитель, Неопределено);
	НастройкаПравДоступа.ПередЗаписьюНовогоОбъектаСПравамиДоступаПользователей(Источник, Отказ, Источник.Родитель);

КонецПроцедуры

Процедура ПриЗаписиОбъектаПравДоступа(Источник, Отказ) Экспорт
	
	Если НЕ Источник.ОбменДанными.Загрузка Тогда
				
		НастройкаПравДоступа.ОбновитьПраваДоступаКИерархическимОбъектамПриНеобходимости(Источник.Ссылка, Источник.ПрошлыйИзмененныйРодительОбъектаДоступа, Отказ);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписиДокументаКонтрольнаяДатаПриЗаписи(Источник, Отказ) Экспорт
	
	Если Источник.ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВнесениеИзмененийСрезПоследних.Документ,
	|	ВнесениеИзмененийСрезПоследних.ДатаДокумента,
	|	ВнесениеИзмененийСрезПоследних.Документ.Номер КАК Номер,
	|	ВнесениеИзмененийСрезПоследних.СуммаНДС,
	|	ВнесениеИзмененийСрезПоследних.СуммаДокумента,
	|	ВнесениеИзмененийСрезПоследних.Проведен,
	|	ВнесениеИзмененийСрезПоследних.ЗначенияРеквизитов,
	|	ВнесениеИзмененийСрезПоследних.ЗначенияТабличныхЧастей,
	|	ВнесениеИзмененийСрезПоследних.Период
	|ИЗ
	|	РегистрСведений.ВнесениеИзменений.СрезПоследних(, Документ = &Документ) КАК ВнесениеИзмененийСрезПоследних";
	
	Запрос.УстановитьПараметр("Документ", Источник.Ссылка);
	
	Результат = Запрос.Выполнить();
	ЕстьИзменения = Ложь;
	Если Результат.Пустой() Тогда
		ЕстьИзменения = Истина;
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Если НЕ Источник.Дата = Выборка.ДатаДокумента Тогда
			ЕстьИзменения = Истина;
		КонецЕсли; 
		Если НЕ Источник.Номер = Выборка.Номер Тогда
			ЕстьИзменения = Истина;
		КонецЕсли; 
		Если НЕ Источник.Проведен = Выборка.Проведен Тогда
			ЕстьИзменения = Истина;
		КонецЕсли; 
		
		Если НЕ ЕстьИзменения Тогда
			СтруктураРеквизитовПоследняяЗапись = Выборка.ЗначенияРеквизитов.Получить();
			Реквизиты = Метаданные.Документы[Источник.Метаданные().Имя].Реквизиты;
			Для каждого Реквизит Из Реквизиты Цикл
				Попытка
					Если НЕ Источник[Реквизит.Имя] = СтруктураРеквизитовПоследняяЗапись[Реквизит.Имя] Тогда
						ЕстьИзменения = Истина;
						Прервать;
					КонецЕсли; 
				Исключение
				КонецПопытки;
			КонецЦикла; 
		КонецЕсли; 
		
		Если НЕ ЕстьИзменения Тогда
			СтруктураТабличныхЧастейПоследняяЗапись = Выборка.ЗначенияТабличныхЧастей.Получить();
			ТабличныеЧасти = Метаданные.Документы[Источник.Метаданные().Имя].ТабличныеЧасти;
			Для каждого ТабличнаяЧасть Из ТабличныеЧасти Цикл
				 ТаблицаЗначенийТабличнойЧастиТекущей = Источник[ТабличнаяЧасть.Имя];
				 Если СтруктураТабличныхЧастейПоследняяЗапись = Неопределено Тогда
				     ЕстьИзменения = Истина;
				 	 Прервать;
				 КонецЕсли; 
				 ТаблицаЗначенийТабличнойЧастиСохраненная = СтруктураТабличныхЧастейПоследняяЗапись[ТабличнаяЧасть.Имя];
				 ТаблицыОдинаковы = НастройкаПравДоступа.СравнитьТаблицыНаборовЗаписей(ТаблицаЗначенийТабличнойЧастиТекущей, ТаблицаЗначенийТабличнойЧастиСохраненная);
				 Если НЕ ТаблицыОдинаковы Тогда
					ЕстьИзменения = Истина;
					Прервать;
				 КонецЕсли; 
			КонецЦикла; 
		КонецЕсли; 
	КонецЕсли;
	
	Если ЕстьИзменения Тогда
		НаборЗаписей = РегистрыСведений.ВнесениеИзменений.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Документ.Значение = Источник.Ссылка;
		НаборЗаписей.Отбор.Документ.Использование = Истина;
		НаборЗаписей.Прочитать();
		
		//Найдем дату запрета изменений       
		//ДатаНачалаМесяца = НачалоМесяца(ДобавитьМесяц(Источник.Дата,1));
		////Пока НЕ (Месяц(ДатаНачалаМесяца) - 1)%3 = 0 Цикл  
		////	ДатаНачалаМесяца = ДобавитьМесяц(ДатаНачалаМесяца,1);
		////КонецЦикла;  //т. е. получили месяц сдачи отчетности при поквартальной сдаче
		//ЧислоКонтрольнойДаты = Константы.ЧислоКонтрольнойДаты.Получить();
		//Если НЕ (ЧислоКонтрольнойДаты > 0 И ЧислоКонтрольнойДаты < 31) Тогда
		//	ЧислоКонтрольнойДаты = 19;
		//КонецЕсли; 
		//ДатаЗапретаИзменений = Дата(Год(ДатаНачалаМесяца),Месяц(ДатаНачалаМесяца), ЧислоКонтрольнойДаты);
		ДатаЗапретаИзменений = НастройкаПравДоступа.ПолучитьДатуЗапретаИзмененийFiscal(Источник, Источник.Дата);
		
		Если ТекущаяДата() >= ДатаЗапретаИзменений Тогда
			ИзмененПослеКонтрольнойДаты = Истина;
		Иначе
			ИзмененПослеКонтрольнойДаты = Ложь;
		КонецЕсли; 
		Если Отказ Тогда
			ИзмененПослеКонтрольнойДаты = Ложь;
		КонецЕсли; 
		Если НЕ ИзмененПослеКонтрольнойДаты Тогда
		    НаборЗаписей.Очистить();
		КонецЕсли; 
		
		НоваяЗапись = НаборЗаписей.Добавить();
		Если Отказ Тогда
			НоваяЗапись.Период = Источник.Дата;
			НоваяЗапись.Пользователь = Источник.Ответственный.Наименование;
		Иначе
			НоваяЗапись.Период = ТекущаяДата();
			НоваяЗапись.Пользователь = ИмяПользователя();
		КонецЕсли; 
		НоваяЗапись.ИзмененПослеКонтрольнойДаты = ИзмененПослеКонтрольнойДаты;
		НоваяЗапись.Документ = Источник.Ссылка;
		НоваяЗапись.СуммаДокумента = Источник.СуммаДокумента;
		НоваяЗапись.ДатаДокумента = Источник.Дата;
		НоваяЗапись.НомерДокумента = Источник.Номер;
		НоваяЗапись.Проведен = Источник.Проведен;
		СтруктураРеквизитов = Новый Структура;
		Реквизиты = Метаданные.Документы[Источник.Метаданные().Имя].Реквизиты;
		Для каждого Реквизит Из Реквизиты Цикл
			СтруктураРеквизитов.Вставить(Реквизит.Имя, Источник[Реквизит.Имя]);
		КонецЦикла; 
		НоваяЗапись.ЗначенияРеквизитов = Новый ХранилищеЗначения(СтруктураРеквизитов);
		СтруктураТабличныхЧастей = Новый Структура;
		ТабличныеЧасти = Метаданные.Документы[Источник.Метаданные().Имя].ТабличныеЧасти;
		СуммаНДСДокумента = 0;
		Для каждого ТабличнаяЧасть Из ТабличныеЧасти Цикл
			ТаблицаЗначенийТабличнойЧасти = Источник[ТабличнаяЧасть.Имя].Выгрузить();
			Если ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("СуммаНДС",Источник.Метаданные(),ТабличнаяЧасть.Имя)  Тогда
				СуммаНДСДокумента = СуммаНДСДокумента + ТаблицаЗначенийТабличнойЧасти.Итог("СуммаНДС");
			ИначеЕсли ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("НДС",Источник.Метаданные(),ТабличнаяЧасть.Имя)  Тогда
                Попытка
					СуммаНДСДокумента = СуммаНДСДокумента + ТаблицаЗначенийТабличнойЧасти.Итог("НДС");
				Исключение
			    КонецПопытки;
			КонецЕсли; 
			СтруктураТабличныхЧастей.Вставить(ТабличнаяЧасть.Имя, ТаблицаЗначенийТабличнойЧасти);
		КонецЦикла; 
		НоваяЗапись.СуммаНДС = СуммаНДСДокумента;
		НоваяЗапись.ЗначенияТабличныхЧастей = Новый ХранилищеЗначения(СтруктураТабличныхЧастей);
		
		//Проверим, существенны ли изменения
		Если Отказ Тогда
		    СущественныеИзменения = Истина;
		Иначе	
			СущественныеИзменения = Ложь;
			Если НЕ Выборка = Неопределено Тогда
				Если НЕ НачалоДня(Источник.Дата) = НачалоДня(Выборка.ДатаДокумента) Тогда
					СущественныеИзменения = Истина;
				ИначеЕсли НЕ СокрЛП(Источник.Номер) = СокрЛП(Выборка.Номер) Тогда
					СущественныеИзменения = Истина;
				ИначеЕсли НЕ Источник.СуммаДокумента = Выборка.СуммаДокумента Тогда
					СущественныеИзменения = Истина;
				ИначеЕсли НЕ СуммаНДСДокумента = Выборка.СуммаНДС Тогда
					СущественныеИзменения = Истина;
				ИначеЕсли НЕ Источник.Проведен = Выборка.Проведен Тогда
					СущественныеИзменения = Истина;
				КонецЕсли; 
			КонецЕсли; 
		КонецЕсли; 
		НоваяЗапись.СущественныеИзменения = СущественныеИзменения;
		
		Попытка
			НаборЗаписей.Записать();
		Исключение
		КонецПопытки;
	КонецЕсли; 
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////
// ЦЕЛОСТНОСТЬ ЗАКРЫТЫХ ПЕРОДОВ

Процедура ПроверитьДатуПроведенияДокументаПередЗаписью(ДокументОбъект, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	Возврат;
	// Если это просто запись - проверку делать не надо
	Если РежимЗаписи = РежимЗаписиДокумента.Запись Тогда
		Возврат;
	КонецЕсли;
	
	// Проверим, что дата проведения документа не попадает в закрытый период
	МодульДокумента = НастройкаПравДоступа.ПолучитьМодульРазработкиДокумента(ДокументОбъект);
	ГраницаЗапрета = НастройкаПравДоступа.ПолучитьУправленческуюГраницуЗапретаИзмененияДанныхМодуля(МодульДокумента);
	Если ОбщегоНазначения.ЕстьРеквизитДокумента("ДатаПроведения", ДокументОбъект.Метаданные()) Тогда
		ДатаПроведенияДокумента = ДокументОбъект.ДатаПроведения;
	Иначе
		ДатаПроведенияДокумента = ДокументОбъект.Дата;
	КонецЕсли;
	Если ГраницаЗапрета <> Неопределено
		И ДатаПроведенияДокумента <= ГраницаЗапрета 
		//добавила Федотова Л., РГ-Софт, вопрос SLI-0003530
		И ?(РольДоступна(Метаданные.Роли.ПолныеПрава) ИЛИ РольДоступна(Метаданные.Роли.ИзменениеДатыЗапрета),Константы.ПрименятьДатуЗапретаДляПолныхПрав.Получить(),Истина)
		//конец добавления
		Тогда
		
		ТекстОшибки = "Дата проведения документа попадает в закрытый период модуля """ + МодульДокумента + """! Модуль закрыт до " + Формат(ГраницаЗапрета, "ДЛФ=DD");
		ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьИЗапомнитьДвиженияПоНалоговымРегистрамПередЗаписью(ДокументОбъект, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	Возврат;
	// Если документ просто записывается - ничего проверять не надо - выходим
	Если РежимЗаписи = РежимЗаписиДокумента.Запись Тогда
		Возврат;
	КонецЕсли;
	
	// начало добавления, RG-Soft, Карасев В.В., 18.04.2016
	Если ДокументОбъект.ДополнительныеСвойства.Свойство("ПровестиВЗакрытомПериоде") И ДокументОбъект.ДополнительныеСвойства.ПровестиВЗакрытомПериоде Тогда
		Возврат;
	КонецЕсли;
	// конец добавления, RG-Soft, Карасев В.В., 18.04.2016
	
	// Если происходит проведение - поместим структуру таблиц движений в дополнительные свойства, для того чтобы потом сверить их с новыми движениями
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		
		// Получим структуру таблиц движений документа по налоговым регистрам
		СтруктураТаблицДвиженийПоНалоговымРегистрам = НастройкаПравДоступа.ПолучитьСтруктуруТаблицДвиженийДокументаПоНалоговымРегистрам(ДокументОбъект, Истина);
        ДокументОбъект.ДополнительныеСвойства.Вставить("СтруктураТаблицСтарыхДвиженийПоНалоговымРегистрам", СтруктураТаблицДвиженийПоНалоговымРегистрам);
					
	Иначе // Если происходит отмена проведения - проверим, что ни одна запись не попадает в закрытый период
		
		// Найдем дату закрытия модуля
		МодульДокумента = НастройкаПравДоступа.ПолучитьМодульРазработкиДокумента(ДокументОбъект);
		ДатаЗакрытия = НастройкаПравДоступа.ПолучитьУправленческуюГраницуЗапретаИзмененияДанныхМодуля(МодульДокумента);
		Если ДатаЗакрытия = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		// Перебираем все наборы записей документа в поисках записи, которая попадает в закрытый период
		ДвиженияДокумента = ДокументОбъект.Движения;
		Для Каждого НаборЗаписей Из ДвиженияДокумента Цикл
			
			// Если в этом регистре нет измерения НалоговыйПериод - значит он не налоговый - его проверять не надо
			МетаданныеНабораЗаписей = НаборЗаписей.Метаданные();
			Если МетаданныеНабораЗаписей.Измерения.Найти("НалоговыйПериод") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
				
			// Ищем в наборе записей строки, попадающие в закрытый период
			НаборЗаписей.Прочитать();
			ТаблицаДвижений = НаборЗаписей.Выгрузить();
			Для Каждого Строка Из ТаблицаДвижений Цикл
					
				Если Строка.Период <= ДатаЗакрытия
					//добавила Федотова Л., РГ-Софт, 17.05.13, вопрос SLI-0003530
					И ?(РольДоступна(Метаданные.Роли.ПолныеПрава),Константы.ПрименятьДатуЗапретаДляПолныхПрав.Получить(),Истина)
					//конец добавления
					Тогда
					ТекстОшибки = "Движения документа попадают в закрытый период модуля """ + МодульДокумента + """! Модуль закрыт до " + Формат(ДатаЗакрытия, "ДЛФ=DD");
					ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ);
					Возврат;

				КонецЕсли;
					
			КонецЦикла; // Для Каждого Строка Из ТаблицаДвижений Цикл
					
		КонецЦикла; // Для Каждого НаборЗаписей Из ДвиженияДокумента Цикл
							
	КонецЕсли; // Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда ... Иначе ... 	
	
КонецПроцедуры

Процедура ПроверитьДвиженияПоНалоговымРегистрамПриПроведении(ДокументОбъект, Отказ, РежимПроведения) Экспорт
	
	Возврат;
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// начало добавления, RG-Soft, Карасев В.В., 18.04.2016
	Если ДокументОбъект.ДополнительныеСвойства.Свойство("ПровестиВЗакрытомПериоде") И ДокументОбъект.ДополнительныеСвойства.ПровестиВЗакрытомПериоде Тогда
		Возврат;
	КонецЕсли;
	// конец добавления, RG-Soft, Карасев В.В., 18.04.2016
	
	// Найдем дату закрытия модуля
	МодульДокумента = НастройкаПравДоступа.ПолучитьМодульРазработкиДокумента(ДокументОбъект);
	ДатаЗакрытия = НастройкаПравДоступа.ПолучитьУправленческуюГраницуЗапретаИзмененияДанныхМодуля(МодульДокумента);
	Если ДатаЗакрытия = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS LFedotova 23.01.2017 12:49:38 - вопрос SLI-0007099
	//Закомментировала почти все ниже в этой процедуре
	
	// } RGS LFedotova 23.01.2017 12:50:28 - вопрос SLI-0007099
		
	//ДвиженияДокумента = ДокументОбъект.Движения;
	//
	//// Получим структуры таблиц старых и новых движений
	//СтруктураТаблицСтарыхДвиженийПоНалоговымРегистрам = ДокументОбъект.ДополнительныеСвойства.СтруктураТаблицСтарыхДвиженийПоНалоговымРегистрам;
	//СтруктураТаблицНовыхДвиженийПоНалоговымРегистрам = НастройкаПравДоступа.ПолучитьСтруктуруТаблицДвиженийДокументаПоНалоговымРегистрам(ДокументОбъект, Ложь);
	//
	//// Перебираем все движения по налоговым регистрам
	//Для Каждого ЭлементСтруктуры Из СтруктураТаблицНовыхДвиженийПоНалоговымРегистрам Цикл
	//	
	//	СтараяТаблицаДвижений = СтруктураТаблицСтарыхДвиженийПоНалоговымРегистрам[ЭлементСтруктуры.Ключ];
	//	НоваяТаблицаДвижений = ЭлементСтруктуры.Значение;
	//	
	//	ЕстьСтарыеДвижения = СтараяТаблицаДвижений.Количество() > 0;
	//	ЕстьНовыеДвижения = НоваяТаблицаДвижений.Количество() > 0;
	//	
	//	// Если старые и новые движения пустые - сравнивать нечего - переходим к следующему регистру
	//	Если НЕ ЕстьСтарыеДвижения
	//		И НЕ ЕстьНовыеДвижения Тогда
	//		
	//		Продолжить;
	//		
	//	КонецЕсли;
	//	
	//	МетаданныеРегистра = ДвиженияДокумента[ЭлементСтруктуры.Ключ].Метаданные();
	//	
	//	// Сформируем массив имен ресурсов регистра
	//	РесурсыРегистра = МетаданныеРегистра.Ресурсы;
	//	МассивРесурсов = Новый Массив;
	//	Для Каждого Ресурс Из РесурсыРегистра Цикл
	//		МассивРесурсов.Добавить(Ресурс.Имя);
	//	КонецЦикла;
	//	
	//	// Если есть только старые движения - будем проверять только их
	//	Если ЕстьСтарыеДвижения
	//		И НЕ ЕстьНовыеДвижения Тогда
	//		
	//		ТаблицаДляСравнения = СтараяТаблицаДвижений;
	//		
	//	// Если есть только новые движения - будем проверять только их
	//	ИначеЕсли НЕ ЕстьСтарыеДвижения
	//		И ЕстьНовыеДвижения Тогда
	//		
	//		ТаблицаДляСравнения = НоваяТаблицаДвижений;
	//		
	//	// Если есть старые и новые движения - сравним их
	//	Иначе
	//		
	//		// Сформируем таблицу значений для сравнения старых и новых движений
	//		ТаблицаДляСравнения = НоваяТаблицаДвижений.Скопировать();
	//		Для Каждого Строка ИЗ СтараяТаблицаДвижений Цикл
	//			
	//			НоваяСтрока = ТаблицаДляСравнения.Добавить();
	//			ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
	//			Для Каждого Ресурс Из МассивРесурсов Цикл		
	//				НоваяСтрока[Ресурс] = -НоваяСтрока[Ресурс];
	//			КонецЦикла;
	//			
	//		КонецЦикла;
	//		
	//		// Сформируем строку группировок для сворачивания
	//		СтрокаГруппировок = "Период";
	//		ИзмеренияРегистра = МетаданныеРегистра.Измерения;
	//		Для Каждого Измерение Из ИзмеренияРегистра Цикл
	//			СтрокаГруппировок = СтрокаГруппировок + ", " + Измерение.Имя;
	//		КонецЦикла;
	//		РеквизитыРегистра = МетаданныеРегистра.Реквизиты;
	//		Для Каждого Реквизит Из РеквизитыРегистра Цикл
	//			СтрокаГруппировок = СтрокаГруппировок + ", " + Реквизит.Имя;	
	//		КонецЦикла;
	//				
	//		// Сформируем строку ресурсов для сворачивания
	//		СтрокаРесурсов = МассивРесурсов[0];
	//		ВерхнийИндексМассиваРесурсов = МассивРесурсов.ВГраница();
	//		Для ы = 1 По ВерхнийИндексМассиваРесурсов Цикл
	//			СтрокаРесурсов = СтрокаРесурсов + ", " + МассивРесурсов[ы];
	//		КонецЦикла;
	//		
	//		// { RGS LFedotova 02.09.2016 18:54:38 - вопрос SLI-0006751
	//		СтрокаГруппировок = СтрокаГруппировок + ", " + "Номер";
	//		// } RGS LFedotova 02.09.2016 18:56:48 - вопрос SLI-0006751
	//		
	//		// Свернем таблицу для сравнения
	//		ТаблицаДляСравнения.Свернуть(СтрокаГруппировок, СтрокаРесурсов);
	//		
	//	КонецЕсли; // Если ЕстьСтарыеДвижения И ЕстьНовыеДвижения
	//	
	//	// Проверим строки, у которых не все ресурсы равны нулю
	//	Для Каждого Строка Из ТаблицаДляСравнения Цикл
	//		
	//		ВсеРесурсыРавныНулю = Истина;
	//		Для Каждого Ресурс Из МассивРесурсов Цикл
	//			
	//			Если Строка[Ресурс] <> 0 Тогда
	//				ВсеРесурсыРавныНулю = Ложь;
	//				Прервать;
	//			КонецЕсли;
	//			
	//		КонецЦикла;
	//		
	//		Если ВсеРесурсыРавныНулю Тогда
	//			Продолжить;
	//		КонецЕсли;
			
			//Если Строка.Период <= ДатаЗакрытия 
			Если ОбщегоНазначения.ЕстьРеквизитДокумента("ДатаПроведения", ДокументОбъект.Метаданные()) Тогда
				ДатаПроведенияДокумента = ДокументОбъект.ДатаПроведения;
			Иначе
				ДатаПроведенияДокумента = ДокументОбъект.Дата;
			КонецЕсли;
				
			Если ДатаПроведенияДокумента <= ДатаЗакрытия 
				//добавила Федотова Л., РГ-Софт, вопрос SLI-0003530
				И ?(РольДоступна(Метаданные.Роли.ПолныеПрава),Константы.ПрименятьДатуЗапретаДляПолныхПрав.Получить(),Истина)
				//конец добавления
				Тогда
				//Добавила Федотова Л., РГ-Софт, 29.09.13, вопрос SLI-0003837 -> 
				ДополнительныеСвойства = ДокументОбъект.ДополнительныеСвойства;
				ЭтоПроведениеПослеУтверждения = ДополнительныеСвойства.Свойство("ЭтоПроведениеПослеУтверждения");
				Если НЕ ЭтоПроведениеПослеУтверждения Тогда
				//<-
					//ТекстОшибки = "Изменились движения документа, которые попадают в закрытый период модуля """ + МодульДокумента + """! Модуль закрыт до " + Формат(ДатаЗакрытия, "ДЛФ=DD");
					ТекстОшибки = "Документ попадает в закрытый период модуля """ + МодульДокумента + """! Модуль закрыт до " + Формат(ДатаЗакрытия, "ДЛФ=DD");
					ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ);
					Возврат;
				//Добавила Федотова Л., РГ-Софт, 29.09.13, вопрос SLI-0003837 -> 
				КонецЕсли;
				//<-
			КонецЕсли;
			
	//	КонецЦикла; // Для Каждого Строка Из ТаблицаДляСравнения Цикл      .
	//	
	//КонецЦикла; // Для Каждого ЭлементСтруктуры Из СтруктураТаблицНовыхДвиженийПоНалоговымРегистрам Цикл 
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////
// УТВЕРЖДЕНИЕ

Процедура ПроверитьУтверждениеДокументаПередЗаписью(ДокументОбъект, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	// { RGS LFedotova 28.06.2018 23:37:55 - вопрос SLI-0007609
	МетаданныеДокумента = ДокументОбъект.Метаданные();
	Если ОбщегоНазначения.ЕстьРеквизитДокумента("ЭтоДокументБиллинга", МетаданныеДокумента) Тогда
		Если ДокументОбъект.ЭтоДокументБиллинга Тогда
			ДокументОбъект.ДополнительныеСвойства.Вставить("ПровестиДокументЛюбойЦеной", Истина);;
		КонецЕсли; 	
	КонецЕсли;  
	// } RGS LFedotova 28.06.2018 23:38:09 - вопрос SLI-0007609 
	
	//Бэкдор Пахоменков 03.07.2014
	Если ДокументОбъект.ДополнительныеСвойства.Свойство("ПровестиДокументЛюбойЦеной") И ДокументОбъект.ДополнительныеСвойства.ПровестиДокументЛюбойЦеной Тогда
		Возврат;		
	КонецЕсли;  
	//<-                                           
	
	// { RGS PBahushevich 9/6/2016 3:12:57 AM - для обменов
	Если ДокументОбъект.ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	// } RGS PBahushevich 9/6/2016 3:13:02 AM - для обменов
	
	// Проверяем надо ли утверждать документ
	Если Не НастройкаПравДоступа.НадоУтверждатьДокумент(ДокументОбъект) Тогда
		Возврат;
	КонецЕсли;
	
	// Если в регистре адресации нет ни одного утверждающего - запускать процесс не надо.
	// РЕШЕНИЕ ВРЕМЕННОЕ. ПОКА НЕ ЗАПОЛНЕН РЕГИСТР АДРЕСАЦИИ И НАДО ПРОВОДИТЬ МНОГО ДОКУМЕНТОВ!!!
	АналиткаАдресации = НастройкаПравДоступа.ПолучитьАналитикуУтвержденияОбъекта(ДокументОбъект);
	МассивУтверждающих = НастройкаПравДоступа.ПолучитьМассивУтверждающихПользователей(АналиткаАдресации);
	Если МассивУтверждающих.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	// Получим параметры проведения
	ДополнительныеСвойства = ДокументОбъект.ДополнительныеСвойства;
	ЭтоПробноеПроведениеПередЗапускомПроцессаУтверждения = ДополнительныеСвойства.Свойство("ЭтоПробноеПроведениеПередЗапускомПроцессаУтверждения");
	ЭтоПроведениеПослеУтверждения = ДополнительныеСвойства.Свойство("ЭтоПроведениеПослеУтверждения");
	
	// Получим статус утверждения документа
	СтатусУтверждения = НастройкаПравДоступа.ПолучитьСтатусУтверждения(ДокументОбъект.Ссылка);
	
	// Сделаем несколько проверок в зависимости от статуса утверждения документа
	ПеречислениеСтатусыУтверждения = Перечисления.СтатусыУтвержденияОбъектов;
	Если СтатусУтверждения = ПеречислениеСтатусыУтверждения.Утверждена Тогда
		
		// Дадим провестись документу автоматически после утверждения 
		Если ЭтоПроведениеПослеУтверждения Тогда
			
		// Дадим провестись документу вручную после утверждения
		ИначеЕсли НЕ ДокументОбъект.Проведен
			И РежимЗаписи = РежимЗаписиДокумента.Проведение
			И НЕ ЭтоПробноеПроведениеПередЗапускомПроцессаУтверждения
			И НЕ ДокументОбъект.Модифицированность() Тогда
			
			ДополнительныеСвойства.Вставить("ЭтоПроведениеПослеУтверждения", Истина);
			
		Иначе
			
			// Откажем в возможности изменить утвержденный документ
			ТекстОшибки = "Документ утвержден. Изменять утвержденный документ запрещено!";
			ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ);
		
		КонецЕсли;

	Иначе	// Если документ не утвержден
					
		// Если документ проводится не в режиме пробного проведения - значит пользователь пытается провести документ, который должен быть утвержден
		//	отказываем ему в этом
		Если РежимЗаписи = РежимЗаписиДокумента.Проведение
			И НЕ ЭтоПробноеПроведениеПередЗапускомПроцессаУтверждения Тогда
			
			ОбщегоНазначения.СообщитьОбОшибке("Документ требует утверждения!", Отказ);
			Возврат;
			
		КонецЕсли;
		
		Если СтатусУтверждения = ПеречислениеСтатусыУтверждения.Новая Тогда
			
			Если ЭтоПробноеПроведениеПередЗапускомПроцессаУтверждения Тогда
				ОбщегоНазначения.СообщитьОбОшибке("Для этого документа уже был запущен процесс утверждения!", Отказ);
			КонецЕсли;

		ИначеЕсли СтатусУтверждения = ПеречислениеСтатусыУтверждения.ВПроцессеУтверждения Тогда
			
			// Откажем в возможности изменить утверждаемый документ
			ТекстОшибки = "Документ находится в процессе утверждения. Изменять утверждаемый документ запрещено!";
			ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ);	
										
		Иначе // Отклонена или нет данных
			
			Если ЭтоПробноеПроведениеПередЗапускомПроцессаУтверждения
				И ДокументОбъект.Модифицированность() Тогда
				
				ТекстОшибки = "Перед запуском процесса утверждения, документ необходимо записать!";
				ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ);
											
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОткрытьФормуЗапускаПроцессаУтвержденияПриНеобходимости(ДокументОбъект, Отказ, РежимПроведения) Экспорт
	
	//Бэкдор Пахоменков 03.07.2014
	Если ДокументОбъект.ДополнительныеСвойства.Свойство("ПровестиДокументЛюбойЦеной") И ДокументОбъект.ДополнительныеСвойства.ПровестиДокументЛюбойЦеной Тогда
		Возврат;		
	КонецЕсли;  
	//<-
	
	// Проверяем надо ли утверждать документ
	Если Не НастройкаПравДоступа.НадоУтверждатьДокумент(ДокументОбъект) Тогда
		//добавила вывод сообщения Федотова Л., РГ-Софт, 26.06.13, вопрос SLI-0003664
		Если ДокументОбъект.ДополнительныеСвойства.Свойство("ЭтоПробноеПроведениеПередЗапускомПроцессаУтверждения") Тогда
			Сообщить("Документ не требует утверждения.");
		КонецЕсли; 
		Возврат;
	КонецЕсли;
		
	// Если были ошибки при попытке провести документ - не запускаем процесс утверждения
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	// Если документ проводится сразу после утверждения - запускать процесс утверждения не надо
	Если ДокументОбъект.ДополнительныеСвойства.Свойство("ЭтоПроведениеПослеУтверждения") Тогда
		Возврат;
	КонецЕсли;
	
	// РЕШЕНИЕ ВРЕМЕННОЕ. ПОКА НЕ ЗАПОЛНЕН РЕГИСТР АДРЕСАЦИИ И НАДО ПРОВОДИТЬ МНОГО ДОКУМЕНТОВ!!!
	АналиткаАдресации = НастройкаПравДоступа.ПолучитьАналитикуУтвержденияОбъекта(ДокументОбъект);
	МассивУтверждающих = НастройкаПравДоступа.ПолучитьМассивУтверждающихПользователей(АналиткаАдресации);
	Если МассивУтверждающих.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	// Документ только начинает утверждаться, поэтому не может быть проведен. Прерываем процесс пробного проведения
	Отказ = Истина;
	ДокументОбъект.ДополнительныеСвойства.Вставить("ПроверкиПередЗапускомПроцессаУтвержденияПройдены", Истина);
	
# Если Клиент Тогда
	// Открываем форму запуска процесса утверждения
	РаботаСДиалогами.ОткрытьФормуЗапускаПроцессаУтверждения(ДокументОбъект);
# КонецЕсли
		
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////
// УЧЕТ ОШИБОК

Процедура ПроизвестиРегламентныеОперацииУчетаОшибокПриЗаписи(Объект, Отказ) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	УчетОшибокЗаполнения.ОбновитьОшибкиВШапкеТипаНеЗаполнен(Объект);
	УчетОшибокЗаполнения.ОбновитьОшибкиВШапкеТипаЗаполненНеправильно(Объект);
	УчетОшибокЗаполнения.ОбновитьОшибкиВТабличныхЧастяхТипаНеЗаполнен(Объект);	
	УчетОшибокЗаполнения.ОбновитьОшибкиВТабличныхЧастяхТипаЗаполненНеправильно(Объект);
	
	СтруктураДанныхОшибокЗаполнения = Объект.ДополнительныеСвойства.СтруктураДанныхОшибокЗаполнения;	
	СтруктураТаблицАвтоматическойРегистрацииОшибок = СтруктураДанныхОшибокЗаполнения.СтруктураТаблицАвтоматическойРегистрацииОшибок;
	
	// Очистим таблицы автоматической регистрации ошибок, чтобы к моменту начала проведения они были пустыми
	СтруктураДанныхОшибокЗаполнения.ПроведениеБыло = Ложь;
	СтруктураТаблицАвтоматическойРегистрацииОшибок.ОшибкиВШапкеТипаНеЗаполнен.Очистить();
	СтруктураТаблицАвтоматическойРегистрацииОшибок.ОшибкиВШапкеТипаЗаполненНеправильно.Очистить();
	СтруктураТаблицАвтоматическойРегистрацииОшибок.ОшибкиВТабличныхЧастяхТипаНеЗаполнен.Очистить();
	СтруктураТаблицАвтоматическойРегистрацииОшибок.ОшибкиВТабличныхЧастяхТипаЗаполненНеправильно.Очистить();
	
КонецПроцедуры

Процедура ПроизвестиРегламентныеОперацииУчетаОшибокПриПроведении(ДокументОбъект, Отказ, РежимПроведения) Экспорт
	
	СтруктураДанныхОшибокЗаполнения = ДокументОбъект.ДополнительныеСвойства.СтруктураДанныхОшибокЗаполнения;
	СтруктураДанныхОшибокЗаполнения.ПроведениеБыло = Истина;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// Если проведение выполнено успешно - считаем, что ручных ошибок больше нет.
	УчетОшибокЗаполнения.УдалитьВсеРучныеОшибкиТипаЗаполненНеправильно("ОшибкиВШапкеТипаЗаполненНеправильно", ДокументОбъект);
	УчетОшибокЗаполнения.УдалитьВсеРучныеОшибкиТипаЗаполненНеправильно("ОшибкиВТабличныхЧастяхТипаЗаполненНеправильно", ДокументОбъект);
		
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////
// ПРОВОДКИ DSS

Процедура ОтвязатьПроводкиDSSПриЗаписи(ДокументОбъект, Отказ) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Если ДокументОбъект.ПометкаУдаления Тогда
		ОбработкаDSSСервер.ВернутьПроводкиДокументаВЖурналы(ДокументОбъект.Ссылка, Отказ);
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////
// ПОМЕТКА НА УДАЛЕНИЕ

Процедура ПроверитьВозможностьПометкиНаУдалениеДокумента(ДокументОбъект, Отказ, РежимЗаписи, РежимПроведения) Экспорт

	Если ДокументОбъект.Проведен
		И ДокументОбъект.ПометкаУдаления Тогда
		
		Сообщить("Нельзя помечать на удаление проведенный документ!", СтатусСообщения.Важное);
		Отказ = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////////
// ПРОВЕРКА СРОКА ДОГОВОРА

Процедура ПриПроведенииДокументаСрокДоговораОбработкаПроведения(Источник, Отказ, РежимПроведения) Экспорт
	
	СрокДоговора = Источник.ДоговорКонтрагента.СрокДоговора;
	Если НЕ СрокДоговора = Дата(1,1,1) Тогда
		Если Источник.Дата > КонецДня(СрокДоговора) Тогда
			Сообщить("Срок договора истек " + Источник.ДоговорКонтрагента.СрокДоговора + ". Выберите другой договор.");
			Отказ = Истина;
		КонецЕсли; 
	КонецЕсли; 
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////////
//ЗАКРЫТЫЙ ПЕРИОД
Процедура ПередЗаписьюДокументаДатыЗапретаИзмененияПередЗаписью(Источник, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	//Богушевич при обменах не проверяем   08.08.2016
	Если Источник.ОбменДанными.Загрузка Тогда 
        Возврат;  
	КонецЕсли; 
	
	//Бэкдор Пахоменков 03.07.2014
	Если Источник.ДополнительныеСвойства.Свойство("ПровестиДокументЛюбойЦеной") И Источник.ДополнительныеСвойства.ПровестиДокументЛюбойЦеной Тогда
		Возврат;		
	КонецЕсли;  

	Если Источник.ДополнительныеСвойства.Свойство("ЭтоПроведениеПослеУтверждения") И Источник.ДополнительныеСвойства.ЭтоПроведениеПослеУтверждения Тогда
		Возврат;		
	КонецЕсли;  
	//<-
	Если Источник.ДополнительныеСвойства.Свойство("ЭтоПробноеПроведениеПередЗапускомПроцессаУтверждения") И Источник.ДополнительныеСвойства.ЭтоПробноеПроведениеПередЗапускомПроцессаУтверждения Тогда
		Возврат;		
	КонецЕсли;  
	//<-	
	Если  РежимЗаписи = РежимЗаписиДокумента.Запись Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.СчетФактураВыданный") и ЗначениеЗаполнено(Источник.ДокументОснование) Тогда 
		Источник = Источник.ДокументОснование.ПолучитьОбъект();
	КонецЕсли;
		
	Сообщение = "";
	Отказ = ДатыЗапретаИзменения.ИзменениеЗапрещено(Источник,,Сообщение);	
	Если Отказ Тогда
	
		Сообщить(Сообщение);	
	
	КонецЕсли; 	
	
КонецПроцедуры

