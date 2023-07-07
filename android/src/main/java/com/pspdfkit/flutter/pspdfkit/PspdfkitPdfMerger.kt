package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import android.net.Uri
import android.util.Log
import com.pspdfkit.document.DocumentSource
import com.pspdfkit.document.PdfDocumentLoader
import com.pspdfkit.document.processor.NewPage
import com.pspdfkit.document.processor.PdfProcessor
import com.pspdfkit.document.processor.PdfProcessorTask
import com.pspdfkit.document.providers.AssetDataProvider
import com.pspdfkit.flutter.pspdfkit.pdfgeneration.PdfPageAdaptor
import com.pspdfkit.flutter.pspdfkit.util.addFileSchemeIfMissing
import io.flutter.plugin.common.MethodChannel
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.schedulers.Schedulers
import java.io.File

class PspdfkitPdfMerger(private val context: Context) {

    fun mergePdf(
            documents: List<String>,
            outputFilePath: String,
            result: MethodChannel.Result
    ) {
        /// add file scheme for each document
        var formattedDocuments = arrayListOf<String>();

        for (doc in documents) {
            formattedDocuments.add(addFileSchemeIfMissing(doc));
        }

        // Load a list of documents to merge.
        val documents = formattedDocuments
                .map { assetName ->
                    PdfDocumentLoader.openDocument(
                            context,
                            DocumentSource(Uri.parse(addFileSchemeIfMissing(assetName)))
                    )
                }
        val task = PdfProcessorTask.empty()
        var totalPageCount = 0
        for (document in documents) {
            for (i in 0 until document.pageCount) {
                // Increment the `totalPageCount` each time to add each new page
                // to the end of the document.
                // However, the pages can be inserted at any index you'd like.
                task.addNewPage(
                        NewPage.fromPage(document, i).build(),
                        totalPageCount++
                )
            }
        }

        // Finally, create the resulting document.
        val outputFile = File(context.filesDir, outputFilePath)
        var dis = PdfProcessor
                .processDocumentAsync(task, outputFile)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    //Log progress
                    Log.d(
                            "PDF Merged",
                            "generatePdf: Document generated Path: ${outputFile.absolutePath}"
                    )
                }, {
                    // Handle the error.
                    result.error("Merge documents", it.message, null)
                }, {
                    result.success(outputFile.absolutePath)
                })

    }


    companion object {

        private var instance: PspdfkitPdfMerger? = null

        fun getInstance(ctx: Context): PspdfkitPdfMerger {
            if (instance == null) {
                instance = PspdfkitPdfMerger(ctx)
            }
            return instance!!
        }
    }
}