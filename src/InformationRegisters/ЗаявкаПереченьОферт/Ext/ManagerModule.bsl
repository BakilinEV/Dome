﻿
&НаСервере
Функция НачалоПериода(Знач НаДату=Неопределено) Экспорт

	Если НаДату = Неопределено Тогда
		НаДату = ТекущаяДата();
	КонецЕсли;
	
	Периодичность = Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений;
	ПериодичностьРегистра = Метаданные.РегистрыСведений.ЗаявкаПереченьОферт.ПериодичностьРегистраСведений;
	Если ПериодичностьРегистра = Периодичность.Квартал Тогда
		НаДату = НачалоКвартала(НаДату);
	ИначеЕсли ПериодичностьРегистра = Периодичность.Месяц Тогда
		НаДату = НачалоМесяца(НаДату);
	КонецЕсли;
	
	Возврат НаДату;
	
КонецФункции

&НаСервере
Функция ЗагрузитьДанные(Знач НаДату=Неопределено, КодРегиона="NV") Экспорт
	
	Данные = ОбменAPI.ПолучитьДанныеAPI("/ServiceMP/hs/ksAPI/", "allorg");
	Если ТипЗнч(Данные) = Тип("Массив") Тогда
		НайденнаяСтрока = Данные[1].Найти(Справочники.Организации.ОрганизацияПоУмолчанию().ИНН, "Код");
		Если НайденнаяСтрока <> Неопределено Тогда
			КодРегиона = НайденнаяСтрока.КодРегиона;
		КонецЕсли;
	ИначеЕсли ТипЗнч(Данные) = Тип("Строка") Тогда 
		Возврат Данные;
	Иначе
		Возврат "Не получен код региона";
	КонецЕсли;
	
	НаДату = НачалоПериода(НаДату);
	
	Данные = ОбменAPI.ПолучитьДанныеAPI(, "OFFERS", Новый Структура("Дт, КодРегиона", НаДату, КодРегиона));
	
	Если ТипЗнч(Данные) = Тип("Строка") Тогда 
		Возврат Данные;
	КонецЕсли;
	
	Данные.Колонки.Добавить("Период");
	Данные.ЗаполнитьЗначения(НаДату, "Период");
	
	НаборЗаписей = РегистрыСведений.ЗаявкаПереченьОферт.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Период.Установить(НаДату);
	НаборЗаписей.Прочитать();
	
	НаборЗаписей.Загрузить(Данные);
	НаборЗаписей.Записать();
		
	Возврат "";
	
КонецФункции

&НаСервере
Функция ЕстьНоменклатураВПериоде(Номенклатура=Неопределено, Период=Неопределено) Экспорт
	
	НаДату = НачалоПериода(Период);
	
	Если Номенклатура = Неопределено Тогда
		Выборка = РегистрыСведений.ЗаявкиПереченьОферт.Выбрать(НаДату, НаДату);
	Иначе
		Выборка = РегистрыСведений.ЗаявкиПереченьОферт.Выбрать(НаДату, НаДату, Новый Структура("Номенклатура", Номенклатура));
	КонецЕсли;
	
	Возврат Выборка.Следующий();
	
КонецФункции
