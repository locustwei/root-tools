package com.rarnu.tools.root.service;

import java.util.List;

import android.app.Notification;
import android.content.Intent;
import android.util.Log;

import com.rarnu.tools.root.GlobalInstance;
import com.rarnu.tools.root.base.BaseService;
import com.rarnu.tools.root.common.Actions;
import com.rarnu.tools.root.common.DataappInfo;
import com.rarnu.tools.root.utils.ApkUtils;
import com.rarnu.tools.root.utils.ListUtils;

public class DataBackupService extends BaseService {

	private Intent inBackup = new Intent(Actions.ACTION_BACKUP);
	private Intent inBackupProgress = new Intent(Actions.ACTION_BACKUP_PROGRESS);

	@Override
	public void initIntent() {
		inBackup.putExtra("operating", true);
	}

	@Override
	public void fiIntent() {
		inBackup.removeExtra("operating");
		inBackup.putExtra("operating", false);

	}

	@Override
	public Intent getSendIntent() {
		return inBackup;
	}

	@Override
	public void doOperation(String command, Notification n) {
		Log.e(getClass().getName(), "doOperation");
		List<DataappInfo> list = ListUtils.getOperateList();
		inBackupProgress.putExtra("size", list.size());
		for (int i = 0; i < list.size(); i++) {

			inBackupProgress.putExtra("position", i + 1);
			inBackupProgress.putExtra("name", GlobalInstance.pm
					.getApplicationLabel(list.get(i).info).toString());
			sendBroadcast(inBackupProgress);

			ApkUtils.backupData(getApplicationContext(), GlobalInstance.pm
					.getApplicationLabel(list.get(i).info).toString(), list
					.get(i).info.sourceDir, list.get(i).info.packageName, list
					.get(i));

		}

	}

	@Override
	public boolean getCommandCondition(String command) {
		Log.e(getClass().getName(), "getCommandCondition");
		return command.equals("backup");
	}

}
