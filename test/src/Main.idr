module Main

import Bindings.RtlSdr
import System.FFI

testOpenClose : IO ()
testOpenClose = do
  putStrLn "opening RTL SDR idx 0"
  h <- rtlsdr_open 0
  case h of
    Nothing => putStrLn "Failed to open device handle"
    Just h => do
      putStrLn $ show $ getTunerType h
      o <- getOffsetTuning h
      putStrLn $ "Tuner offset: " ++ (show o)
      g <- getTunerGain h
      putStrLn $ "Gain: " ++ (show g)
      f <- getCenterFreq h
      putStrLn $ "Freq: " ++ (show f)

      _ <- rtlsdr_close h
      putStrLn "Done, closing.."

testAM : IO ()
testAM = do
  putStrLn "opening RTL SDR idx 0"
  h <- rtlsdr_open 0
  case h of
    Nothing => putStrLn "Failed to open device handle"
    Just h => do
      let fq = 133250000 -- YBTH AWIS
--      let sr = 100

      _ <- setTunerGainMode h False
      _ <- setAGCMode h True -- ON
--      let _ = set_sample_rate h sr
      _ <- setCenterFreq h fq

      f <- getCenterFreq h
      putStrLn $ "Freq set to: " ++ (show f)

      fc <- getFreqCorrection h
      putStrLn $ "Freq correction set to: " ++ (show fc)

      -- flush buffer
      _ <- fromPrim $ reset_buffer h

      -- read_sync(device, buffer, buffer_len, &len);
      -- read_sync: Ptr RtlSdrHandle -> AnyPtr -> Int -> Ptr Int -> PrimIO Int
      let bl = 8192 -- buffer length
      b <- malloc bl -- prim__getNullAnyPtr -- buffer
      l <- prim__castPtr <$> malloc 1 --: Ptr Int -- read length
      _ <- fromPrim $ read_sync h b bl l

      let lref = idris_rtlsdr_read_refint l
      free $ prim__forgetPtr l
      putStrLn $ "read buffer length = " ++ (show lref)

      -- print out the buffer

      free b

      _ <- rtlsdr_close h
      putStrLn "Done, closing.."


testDeviceFound : IO ()
testDeviceFound = do
  let n = get_device_count
  putStrLn $ "Device Count: " ++ show n
  for_ [0..n-1] $ \k => putStrLn $ "Device Name: " ++ get_device_name k

main : IO ()
main = do
  testDeviceFound
  testOpenClose
  testAM
